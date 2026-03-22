#include <jni.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/wait.h>
#include <android/log.h>

#define LOG_TAG "ServcVPN-JNI"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

static pid_t tun2socks_pid = -1;

JNIEXPORT jint JNICALL
Java_com_servcvpn_servc_1vpn_ServcVpnService_nativeStartTun2Socks(
    JNIEnv *env, jobject thiz, jint tunFd, jstring binaryPath, jstring proxyAddr) {

    const char *binary = (*env)->GetStringUTFChars(env, binaryPath, NULL);
    const char *proxy = (*env)->GetStringUTFChars(env, proxyAddr, NULL);

    // Build fd device string
    char fdDevice[64];
    snprintf(fdDevice, sizeof(fdDevice), "fd://%d", (int)tunFd);

    LOGI("fork+exec tun2socks: binary=%s fd=%d proxy=%s", binary, (int)tunFd, proxy);

    // Clear close-on-exec flag on TUN fd BEFORE fork
    int flags = fcntl((int)tunFd, F_GETFD);
    if (flags >= 0) {
        fcntl((int)tunFd, F_SETFD, flags & ~FD_CLOEXEC);
        LOGI("Cleared CLOEXEC on fd=%d (flags was %d)", (int)tunFd, flags);
    } else {
        LOGE("fcntl F_GETFD failed for fd=%d", (int)tunFd);
    }

    pid_t pid = fork();
    if (pid < 0) {
        LOGE("fork failed: %s", strerror(errno));
        (*env)->ReleaseStringUTFChars(env, binaryPath, binary);
        (*env)->ReleaseStringUTFChars(env, proxyAddr, proxy);
        return -1;
    }

    if (pid == 0) {
        // Child process - exec tun2socks
        // The TUN fd is inherited from parent (CLOEXEC was cleared)

        // Close stdin/stdout/stderr and redirect to /dev/null
        // to avoid blocking on pipe writes
        int devnull = open("/dev/null", O_RDWR);
        if (devnull >= 0) {
            dup2(devnull, STDOUT_FILENO);
            dup2(devnull, STDERR_FILENO);
            if (devnull > STDERR_FILENO) close(devnull);
        }

        // exec tun2socks
        execl(binary, binary,
              "-device", fdDevice,
              "-proxy", proxy,
              "-loglevel", "warn",
              (char *)NULL);

        // If exec fails
        _exit(127);
    }

    // Parent process
    tun2socks_pid = pid;
    LOGI("tun2socks forked with pid=%d", pid);

    (*env)->ReleaseStringUTFChars(env, binaryPath, binary);
    (*env)->ReleaseStringUTFChars(env, proxyAddr, proxy);

    // Wait briefly and check if child is still alive
    usleep(500000); // 500ms
    int status;
    pid_t result = waitpid(pid, &status, WNOHANG);
    if (result == pid) {
        // Child already exited
        int exitCode = WIFEXITED(status) ? WEXITSTATUS(status) : -1;
        LOGE("tun2socks died immediately with exit code %d", exitCode);
        tun2socks_pid = -1;
        return -exitCode;
    }

    LOGI("tun2socks is running (pid=%d)", pid);
    return pid;
}

JNIEXPORT void JNICALL
Java_com_servcvpn_servc_1vpn_ServcVpnService_nativeStopTun2Socks(
    JNIEnv *env, jobject thiz) {

    if (tun2socks_pid > 0) {
        LOGI("Killing tun2socks pid=%d", tun2socks_pid);
        kill(tun2socks_pid, SIGTERM);
        usleep(100000); // 100ms
        kill(tun2socks_pid, SIGKILL);
        waitpid(tun2socks_pid, NULL, 0);
        tun2socks_pid = -1;
    }
}

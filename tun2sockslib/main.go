package main

/*
#include <signal.h>
#include <string.h>

// Save and restore JVM signal handlers that Go runtime overwrites
static struct sigaction old_sa[32];
static int saved_signals[] = {SIGBUS, SIGFPE, SIGSEGV, SIGPIPE, SIGABRT, SIGTRAP, 0};

static void save_signal_handlers() {
    for (int i = 0; saved_signals[i] != 0; i++) {
        sigaction(saved_signals[i], NULL, &old_sa[i]);
    }
}

static void restore_signal_handlers() {
    for (int i = 0; saved_signals[i] != 0; i++) {
        sigaction(saved_signals[i], &old_sa[i], NULL);
    }
}
*/
import "C"

import (
	"fmt"
	"os"
	"os/signal"
	"sync"

	"github.com/xjasonlyu/tun2socks/v2/engine"
)

func init() {
	// Save JVM signal handlers before Go runtime installs its own
	C.save_signal_handlers()
}

var mu sync.Mutex
var running bool

//export StartTun2Socks
func StartTun2Socks(fd C.int, proxyAddr *C.char) *C.char {
	mu.Lock()
	defer mu.Unlock()

	if running {
		return C.CString("already running")
	}

	// Restore JVM signal handlers
	signal.Reset()
	C.restore_signal_handlers()

	goFd := int(fd)
	goProxy := C.GoString(proxyAddr)

	// Verify fd is valid
	f := os.NewFile(uintptr(goFd), "/dev/tun")
	if f == nil {
		return C.CString(fmt.Sprintf("invalid fd: %d", goFd))
	}

	device := fmt.Sprintf("fd://%d", goFd)

	key := &engine.Key{
		Proxy:    goProxy,
		Device:   device,
		LogLevel: "warn",
		MTU:      1500,
	}

	engine.Insert(key)

	go func() {
		engine.Start()
	}()

	running = true
	return nil
}

//export StopTun2Socks
func StopTun2Socks() {
	mu.Lock()
	defer mu.Unlock()

	if running {
		engine.Stop()
		running = false
	}
}

func main() {}

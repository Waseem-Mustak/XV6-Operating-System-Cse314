# CSE 314 – Operating Systems Offlines (xv6 & Synchronization)

This repository contains my complete implementations for **CSE 314 (Operating Systems)** offline assignments.  
The work spans **shell scripting**, **xv6 kernel development**, **system calls**, **CPU scheduling**, **threading**, and **synchronization primitives**.

All assignments were implemented on top of the **original xv6-riscv codebase**, strictly following the provided specifications and submission guidelines.

---

## 📌 Assignment Overview

### 🔹 Offline 1: Bash Autograder Design
**Technologies:** Bash, Linux Shell  
**Concepts:** Automation, File Processing, Evaluation Systems  

- Designed a fully automated **Bash-based autograder**
- Parsed assignment configuration from an input file
- Supported both **archived** and **non-archived** submissions
- Automatically:
  - Extracted submissions
  - Verified student IDs and programming languages
  - Executed programs and captured output
  - Compared outputs with expected results
  - Applied penalties for mismatches, missing submissions, guideline violations, and plagiarism
- Generated:
  - `marks.csv` containing detailed evaluation results
  - Organized `checked/` and `issues/` directories

---

### 🔹 Offline 2: xv6 System Calls & Shell Enhancements
**Concepts:** Kernel Programming, System Calls, Process Management  

#### Implemented System Calls
- **`trace(int syscall_number)`**
  - Traces a specific system call for a process
  - Prints PID, syscall name, arguments, and return value
- **`info(struct procInfo *)`**
  - Returns aggregated system and memory statistics
  - Safe user–kernel memory transfer using `copyin()` and `copyout()`

#### Shell Enhancement
- Added `!!` command support in xv6 shell
- Kernel-managed command history with proper locking
- Bonus: support for `!! n` to execute the *n-th previous* command

---

### 🔹 Offline 3: xv6 Scheduler – MLFQ with Lottery & Aging
**Concepts:** CPU Scheduling, Fairness, Starvation Prevention  

- Replaced default Round-Robin scheduler with **Multilevel Feedback Queue (MLFQ)**
- Two scheduling queues:
  - **Queue 0:** Lottery Scheduling
  - **Queue 1:** Round-Robin
- Features:
  - Time-slice based promotion and demotion
  - Aging mechanism to prevent starvation
  - Ticket inheritance across `fork()`
- Added system calls:
  - `settickets(int)`
  - `getpinfo(struct pstat *)`
- Implemented user programs:
  - `dummyproc.c`
  - `testprocinfo.c`
- Detailed scheduler logging for debugging and evaluation

---

### 🔹 Offline 4: Museum Visitor Synchronization Problem
**Concepts:** Thread Synchronization, Locks, Producer–Consumer, Reader–Writer  

- Simulated visitor movement inside a museum using threads
- Implemented synchronization for:
  - Stair movement with step-level locking
  - Gallery 1 occupancy constraints
  - Gallery transition using Producer–Consumer pattern
  - Photo booth access using Reader–Writer logic
- Ensured:
  - No busy waiting
  - Correct priority handling for premium visitors
  - Proper timestamp ordering
- Used **Poisson distribution** for visitor arrival randomness

---

### 🔹 Offline 5: xv6 Threading & Synchronization
**Concepts:** Threads, Shared Address Space, Kernel Synchronization  

#### Thread System Calls
- **`thread_create(void (*fcn)(void*), void *arg, void *stack)`**
- **`thread_join(int thread_id)`**
- **`thread_exit(void)`**

- Implemented kernel threads sharing the same address space
- Managed per-thread stacks (one page each)
- Added memory reference tracking to avoid premature deallocation

#### Synchronization Primitives
- **Spinlock**
  - `thread_spin_init`
  - `thread_spin_lock`
  - `thread_spin_unlock`
- **Mutex**
  - `thread_mutex_init`
  - `thread_mutex_lock`
  - `thread_mutex_unlock`
  - Uses `sleep()` to avoid busy waiting

- Verified correctness using concurrent balance update example (`threads.c`)

---

## 🛠 Build & Run Instructions

```bash
# Clone xv6
git clone https://github.com/mit-pdos/xv6-riscv.git
cd xv6-riscv

# Apply patch
git apply <studentID>.patch

# Build and run
make qemu

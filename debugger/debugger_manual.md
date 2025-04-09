# Enhanced GDB Debugger Manual

## Overview

The Enhanced GDB Debugger is a powerful tool that extends GDB's capabilities with interactive key controls, simplified commands, and advanced memory examination features. This manual provides comprehensive instructions on how to use the debugger effectively.


## Basic Commands

The debugger provides shortened commands for common operations:

| Short | Long Form     | Description                           |
|-------|---------------|---------------------------------------|
| `h`   | `help`        | Display help information              |
| `r`   | `regs`        | Show all registers                    |
| `s`   | `step`        | Step one instruction and show registers |
| `m`   | `mem`         | Examine memory at specified address   |
| `sd`  | `start_debug` | Set breakpoint at main and run        |
| `se`  | `start_entry` | Show entry point information          |
| `i`   | `interactive` | Start interactive debugging mode      |
| `bt`  | -             | Show backtrace                        |
| `c`   | -             | Continue execution                    |
| `q`   | -             | Quit debugger                         |

## Getting Started

1. Launch the debugger with your program:
   ```bash
   ./gdb_enhanced_debugger.sh your_program
   ```

2. Start debugging at the main function:
   ```
   (gdb) sd
   ```

3. Or view entry point information and set a custom breakpoint:
   ```
   (gdb) se
   ```

4. Use `h` at any time to see available commands:
   ```
   (gdb) h
   ```

## Memory Examination

The `m` command allows you to examine memory with various formats:

```
(gdb) m ADDRESS [FORMAT]
```

Example:
```
(gdb) m 0x12345678
(gdb) m $rsp 10x
```

### Format Specifiers

- `x`: hexadecimal
- `d`: decimal
- `u`: unsigned decimal
- `o`: octal
- `t`: binary
- `f`: floating point
- `a`: address
- `i`: instruction
- `c`: character
- `s`: string

### Size Modifiers

- `b`: byte (1 byte)
- `h`: halfword (2 bytes)
- `w`: word (4 bytes)
- `g`: giant word (8 bytes)

Example: `10xb` means "10 bytes in hex format"

## Interactive Mode

Interactive mode provides single-key commands for efficient debugging:

1. Enter interactive mode:
   ```
   (gdb) i
   ```

2. Use the following keys:
   - `s`: Step one instruction and show next instruction
   - `r`: Show key registers (rax, rbx, rcx, etc.)
   - `a`: Show all registers
   - `b`: Set a breakpoint at a specific address
   - `m`: Examine memory at a specific address
   - `w`: Write to memory at a specific address
   - `f`: Continue execution
   - `c`: Clear the screen
   - `q`: Quit interactive mode

### Memory Examination in Interactive Mode

When you press `m` in interactive mode:
1. Enter the address to examine
2. Enter the length of memory to read
3. Choose whether to specify a format
4. If yes, enter the format (e.g., `ib` for instructions as bytes)

### Memory Writing in Interactive Mode

When you press `w` in interactive mode:
1. Enter the address to write to
2. Select the format (b/h/w/g)
3. Enter the value to write in hex
4. The debugger will write the value and verify it

## Advanced Features

### Setting Breakpoints

In standard mode:
```
(gdb) break *0x12345678
```

In interactive mode, press `b` and enter the address.

### Viewing Registers

View all registers:
```
(gdb) r
```

View specific registers in interactive mode by pressing `r`.

### Stepping Through Code

Step one instruction:
```
(gdb) s
```

In interactive mode, press `s` to step and automatically view the next instruction.

## Tips and Tricks

1. **Quick Start**: Use `sd` to immediately break at main and start debugging.

2. **Memory Navigation**: When examining memory, use expressions like `$rsp+16` to navigate relative to registers.

3. **Format Combinations**: Combine format specifiers and size modifiers for powerful memory examination:
   ```
   (gdb) m $rip 5i
   ```
   Shows 5 instructions starting at the current instruction pointer.

4. **Interactive Efficiency**: Interactive mode is most efficient for stepping through code and examining memory on the fly.

5. **Clearing the Screen**: In interactive mode, press `c` to clear the screen and redisplay the menu.

## Troubleshooting

### Common Issues

1. **Pagination Messages**: If you see pagination prompts, the pagination settings might not be applied. Try restarting the debugger.

2. **Memory Access Errors**: When examining memory outside valid regions, you'll get an error. Verify addresses before examining.

3. **Breakpoint Issues**: If a breakpoint can't be set, ensure the address is valid and within the program's memory space.

### Error Messages

- "Error: Address required": You must provide a valid memory address.
- "Error: Invalid format": The format specifier is not recognized.
- "Cannot access memory at address": The address is not valid or accessible.

## Example Debugging Session

```
$ ./gdb_enhanced_debugger.sh my_program
GDB debugger commands:
  s/step       - Step and show registers
  r/regs       - Show registers
  m/mem ADDR   - Examine memory
  bt           - Backtrace
  c            - Continue
  q            - Quit
  sd/start     - Break at main
  se/entry     - Show entry point
  h/help       - Show help
  i/inter      - Interactive mode

Starting GDB...

(gdb) sd
Breakpoint set at main()
...registers displayed...

(gdb) i
Interactive mode. Press 'q' to exit.
<| s:Step | r:Regs | a:AllRegs | c:Clear | q:Quit |>
<| b:Break | m:Memory | w:Write | f:Continue |>

...press 's' several times to step through code...
...press 'm' to examine memory...
...press 'q' to exit interactive mode...

(gdb) q
```

## Conclusion

The Enhanced GDB Debugger combines the power of GDB with a streamlined interface and interactive controls. By using the shortened commands and interactive mode, you can debug programs more efficiently and gain deeper insights into their execution.

For additional help or to report issues, please contact the script maintainer.
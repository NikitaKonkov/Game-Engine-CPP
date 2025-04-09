#!/bin/bash
# Enhanced GDB debugger wrapper script with interactive key controls
# Usage: ./gdb_enhanced_debugger.sh [executable] [args...]

# Check if GDB is available
if ! command -v gdb &> /dev/null; then
    echo "Error: GDB is required but not found"
    exit 1
fi

# Create a temporary GDB initialization file
GDBINIT_FILE=$(mktemp gdbinit_XXXXXX.txt)

# Ensure the temporary file is deleted on exit
trap "rm -f $GDBINIT_FILE" EXIT

# Write GDB initialization commands to the file
cat > "$GDBINIT_FILE" << 'EOF'
# Custom GDB initialization file for enhanced debugging

# Disable pagination immediately
set pagination off
set height 0
set width 0

# Define short commands for common operations
define r
    info registers
end

define s
    stepi
    info registers
end

define m
    if $argc == 0
        echo Usage: m ADDR [FMT]\n
        echo Ex: m 0x12345678 or m $rsp\n
        echo Formats: x (hex), d (dec), s (str)\n
    else
        if $argc == 1
            x/x $arg0
        else
            x/$arg1 $arg0
        end
    end
end

# Alias the short commands to their longer versions
define regs
    r
end

define mem
    m $arg0 $arg1
end

# Define a command to start debugging at main
define sd
    break main
    echo BP @ main()\n
    run
    info registers
end

define start_debug
    sd
end

# Define a command to start debugging at entry point
define se
    info files
    echo To set BP at entry: break *0xADDR\n
    echo Then type 'run'\n
end

define start_at_entry
    se
end

# Set some helpful defaults
set disassembly-flavor intel

# Print a shorter welcome message
echo GDB Debugger. Type 'h' for help.\n

# Define a help command that doesn't trigger pagination
define h
    echo Commands:\n
    echo   s/step       - Step and show regs\n
    echo   r/regs       - Show registers\n
    echo   m/mem ADDR   - Examine memory\n
    echo   bt           - Backtrace\n
    echo   c            - Continue\n
    echo   q            - Quit\n
    echo   sd/start     - Break @ main\n
    echo   se/entry     - Show entry point\n
    echo   h/help       - This help\n
    echo   i/inter      - Interactive mode\n
end

define help
    h
end

define help_debug
    h
end

# Python script for interactive key-based debugging
python
import sys
import os
import gdb

# Try to import msvcrt for Windows, otherwise use Unix approach
try:
    import msvcrt
    is_windows = True
except ImportError:
    import termios
    import tty
    import select
    is_windows = False

# Information about format specifiers and size modifiers
memory_info = """
Format Specifiers:
x: hex, d: dec, u: unsigned, o: octal, t: binary
f: float, a: addr, i: instr, c: char, s: string

Size Modifiers:
b: byte (1B), h: halfword (2B), w: word (4B), g: giant (8B)
"""

default_format = "ib"

def wait_for_key():
    """Wait for a single key press."""
    if is_windows:
        # Windows implementation
        if msvcrt.kbhit():
            return msvcrt.getch().decode('utf-8')
    else:
        # Unix implementation
        old_settings = termios.tcgetattr(sys.stdin)
        try:
            tty.setcbreak(sys.stdin.fileno())
            if select.select([sys.stdin], [], [], 0.1)[0]:
                return sys.stdin.read(1)
        finally:
            termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)
    return None

def clear_screen():
    """Clear the terminal screen."""
    if is_windows:
        os.system('cls')
    else:
        os.system('clear')

class InteractiveDebugger(gdb.Command):
    """Start interactive key-based debugging mode"""
    
    def __init__(self):
        super(InteractiveDebugger, self).__init__("i", gdb.COMMAND_USER)
        # Also register the long-form command
        InteractiveLong()
    
    def print_menu(self):
        """Print the command menu."""
        print("<| s:Step | r:Regs | a:AllRegs | c:Clear | q:Quit |>")
        print("<| b:Break | m:Memory | w:Write | f:Continue |>")
    
    def invoke(self, arg, from_tty):
        """Start the interactive debugging session."""
        print("Interactive mode. Press 'q' to exit.")
        self.print_menu()
        
        while True:
            key = wait_for_key()
            if key is None:
                continue
                
            if key == 's':
                gdb.execute("x/i $pc")
                gdb.execute("si")
                
            elif key == 'f':
                gdb.execute("continue")
                
            elif key == 'r':
                gdb.execute("info registers rax rbx rcx rdx rsi rdi rbp rsp r8 r9 r10 r11 r12 r13 r14 r15 rip cs ss ds es fs gs")
                
            elif key == 'a':
                gdb.execute("info registers")
                
            elif key == 'b':
                try:
                    bp = input("BP addr (e.g., 0x7C00): ")
                    if not bp.startswith("0x"):
                        bp = "0x" + bp
                    gdb.execute("break *" + bp)
                except gdb.error as e:
                    print("Error:", str(e))
                    
            elif key == 'c':
                clear_screen()
                self.print_menu()
                
            elif key == 'q':
                print("Exiting interactive mode")
                break
                
            elif key == 'm':
                print(memory_info)
                print()
                try:
                    addr = input("Addr (e.g., 0x7C00): ")
                    if addr == "":
                        print("Error: Addr required")
                        continue
                    length = input("Length: ")
                    fmt = input("Format? (y/n): ")
                    if fmt.lower() == "y":
                        default_format = input("Format (e.g., ib): ")
                    gdb.execute(f"x/{length}{default_format} {addr}")
                except Exception as e:
                    print(f"Error: {str(e)}")
                    
            elif key == 'w':
                print("Memory Write")
                print()
                try:
                    addr = input("Addr (e.g., 0x7C00): ")
                    if addr == "":
                        print("Error: Addr required")
                        continue
                        
                    fmt_info = "Formats: b:byte(1B), h:half(2B), w:word(4B), g:giant(8B)"
                    print(fmt_info)
                    
                    fmt = input("Format (b/h/w/g): ").lower()
                    if fmt not in ['b', 'h', 'w', 'g']:
                        print("Error: Invalid format")
                        continue
                        
                    val = input("Value (hex, e.g., 0xFF): ")
                    if not val.startswith("0x"):
                        val = "0x" + val
                        
                    # Get the inferior (target process)
                    inferior = gdb.selected_inferior()
                    
                    # Determine size based on format
                    size_map = {'b': 1, 'h': 2, 'w': 4, 'g': 8}
                    size = size_map[fmt]
                    
                    # Convert value to bytes
                    int_value = int(val, 16)
                    byte_value = int_value.to_bytes(size, byteorder='little')
                    
                    # Write to memory
                    inferior.write_memory(int(addr, 16), byte_value)
                    
                    # Verify the write by reading back
                    written = inferior.read_memory(int(addr, 16), size)
                    print(f"Write OK: {written.tobytes().hex()}")
                    
                    # Show the instruction at this address if it might be code
                    try:
                        gdb.execute(f"x/i {addr}")
                    except:
                        pass
                        
                except Exception as e:
                    print(f"Error: {str(e)}")
                    
            else:
                self.print_menu()

class InteractiveLong(gdb.Command):
    """Long form of interactive command"""
    def __init__(self):
        super(InteractiveLong, self).__init__("interactive", gdb.COMMAND_USER)
    
    def invoke(self, arg, from_tty):
        gdb.execute("i")

# Initialize the interactive debugger command
InteractiveDebugger()
end

# Run the help command
h
EOF

# Display instructions
echo "GDB debugger commands:"
echo "  s/step       - Step and show registers"
echo "  r/regs       - Show registers"
echo "  m/mem ADDR   - Examine memory"
echo "  bt           - Backtrace"
echo "  c            - Continue"
echo "  q            - Quit"
echo "  sd/start     - Break at main"
echo "  se/entry     - Show entry point"
echo "  h/help       - Show help"
echo "  i/inter      - Interactive mode"
echo ""
echo "Type 'sd' to run and break at main."
echo "Type 'i' for interactive mode."
echo ""
echo "Starting GDB..."

# Launch GDB with the initialization file and additional options to disable pagination
if [ $# -eq 0 ]; then
    echo "Error: No executable specified"
    echo "Usage: $0 [executable] [args...]"
    exit 1
else
    # Use a combination of environment variables and command-line options to disable pagination
    PAGER="" gdb -x "$GDBINIT_FILE" -ex "set pagination off" -ex "set height 0" -ex "set width 0" "$@"
fi
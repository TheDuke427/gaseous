#!/usr/bin/env python3

import os
import sys
import time
import subprocess
import logging
from pathlib import Path
import shutil

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def find_unrar_binary():
    """Try to find unrar binary in various locations."""
    possible_paths = [
        '/usr/bin/unrar',
        '/usr/local/bin/unrar',
        '/bin/unrar',
        '/sbin/unrar',
        shutil.which('unrar')
    ]
    
    for path in possible_paths:
        if path and os.path.exists(path):
            logger.info(f"Found unrar at: {path}")
            return path
    
    # Try to find it with which command
    try:
        result = subprocess.run(['which', 'unrar'], capture_output=True, text=True)
        if result.returncode == 0 and result.stdout.strip():
            path = result.stdout.strip()
            logger.info(f"Found unrar via which: {path}")
            return path
    except:
        pass
    
    return None

def extract_rar(rar_file, extract_path, unrar_path, delete_after=False):
    """Extract a RAR file to the specified path."""
    try:
        logger.info(f"Extracting {rar_file} to {extract_path}")
        
        # Create extraction subdirectory based on RAR filename
        rar_name = Path(rar_file).stem
        target_dir = Path(extract_path) / rar_name
        target_dir.mkdir(parents=True, exist_ok=True)
        
        # Extract using unrar
        cmd = [unrar_path, 'x', '-o+', '-y', str(rar_file), str(target_dir) + '/']
        logger.info(f"Running command: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            logger.info(f"Successfully extracted {rar_file}")
            
            if delete_after:
                os.remove(rar_file)
                logger.info(f"Deleted {rar_file} after extraction")
            
            return True
        else:
            logger.error(f"Failed to extract {rar_file}")
            logger.error(f"Exit code: {result.returncode}")
            logger.error(f"stderr: {result.stderr}")
            logger.error(f"stdout: {result.stdout}")
            return False
            
    except Exception as e:
        logger.error(f"Error extracting {rar_file}: {str(e)}")
        return False

def scan_for_rar_files(source_path):
    """Scan directory for RAR files."""
    rar_files = []
    
    try:
        logger.info(f"Scanning {source_path} for RAR files...")
        for root, dirs, files in os.walk(source_path):
            for file in files:
                if file.lower().endswith('.rar'):
                    full_path = os.path.join(root, file)
                    rar_files.append(full_path)
                    logger.info(f"Found: {full_path}")
    except Exception as e:
        logger.error(f"Error scanning directory: {str(e)}")
    
    logger.info(f"Total RAR files found: {len(rar_files)}")
    return rar_files

def main():
    if len(sys.argv) < 5:
        logger.error("Missing required arguments")
        sys.exit(1)
    
    source_path = sys.argv[1]
    extract_path = sys.argv[2]
    delete_after = sys.argv[3].lower() == 'true'
    watch_mode = sys.argv[4].lower() == 'true'
    
    logger.info("Unrar Tool Started")
    logger.info(f"Monitoring path: {source_path}")
    logger.info(f"Extract to: {extract_path}")
    logger.info(f"Delete after extract: {delete_after}")
    logger.info(f"Watch mode: {watch_mode}")
    
    # Check if source path exists
    if not os.path.exists(source_path):
        logger.error(f"Source path does not exist: {source_path}")
        sys.exit(1)
    
    # Find unrar binary
    unrar_path = find_unrar_binary()
    
    if not unrar_path:
        logger.error("unrar binary not found!")
        logger.info("Checking what's installed...")
        
        # Debug: List installed packages
        try:
            result = subprocess.run(['apk', 'list', '--installed'], capture_output=True, text=True)
            logger.info("Installed packages:")
            for line in result.stdout.split('\n'):
                if 'rar' in line.lower():
                    logger.info(f"  {line}")
        except:
            pass
        
        # Debug: Check PATH
        logger.info(f"PATH: {os.environ.get('PATH', 'Not set')}")
        
        # Debug: List /usr/bin
        logger.info("Contents of /usr/bin:")
        try:
            for file in os.listdir('/usr/bin'):
                if 'rar' in file.lower():
                    logger.info(f"  {file}")
        except:
            pass
            
        logger.error("Cannot continue without unrar. Exiting.")
        sys.exit(1)
    
    # Test unrar
    try:
        result = subprocess.run([unrar_path], capture_output=True, text=True)
        logger.info("unrar is available and working")
    except Exception as e:
        logger.error(f"unrar test failed: {str(e)}")
        sys.exit(1)
    
    processed_files = set()
    
    while True:
        try:
            # Find all RAR files
            rar_files = scan_for_rar_files(source_path)
            
            # Process new RAR files
            for rar_file in rar_files:
                if rar_file not in processed_files:
                    logger.info(f"Processing: {rar_file}")

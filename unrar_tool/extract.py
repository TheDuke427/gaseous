#!/usr/bin/env python3

import os
import sys
import time
import subprocess
import logging
from pathlib import Path

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def extract_rar(rar_file, extract_path, delete_after=False):
    """Extract a RAR file to the specified path."""
    try:
        logger.info(f"Extracting {rar_file} to {extract_path}")
        
        # Create extraction subdirectory based on RAR filename
        rar_name = Path(rar_file).stem
        target_dir = Path(extract_path) / rar_name
        target_dir.mkdir(parents=True, exist_ok=True)
        
        # Extract using unrar
        cmd = ['/usr/bin/unrar', 'x', '-o+', '-y', str(rar_file), str(target_dir) + '/']
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
                    # Skip part files except part1
                    if '.part' in file.lower() and not 'part1.rar' in file.lower() and not 'part01.rar' in file.lower():
                        continue
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
    
    # Test if unrar is available
    try:
        result = subprocess.run(['/usr/bin/unrar'], capture_output=True, text=True)
        logger.info("unrar is available for extraction")
    except FileNotFoundError:
        logger.error("unrar binary not found at /usr/bin/unrar")
        # Try to find it elsewhere
        try:
            result = subprocess.run(['which', 'unrar'], capture_output=True, text=True)
            if result.returncode == 0 and result.stdout.strip():
                logger.info(f"Found unrar at: {result.stdout.strip()}")
            else:
                logger.error("unrar not found in system PATH")
                sys.exit(1)
        except Exception as e:
            logger.error(f"Cannot locate unrar: {str(e)}")
            sys.exit(1)
    except Exception as e:
        logger.error(f"Error testing unrar: {str(e)}")
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
                    
                    if extract_rar(rar_file, extract_path, delete_after):
                        processed_files.add(rar_file)
                    else:
                        logger.warning(f"Failed to process {rar_file}, will retry later")
            
            if not watch_mode:
                if len(rar_files) == 0:
                    logger.info("No RAR files found in source path")
                logger.info("Single run complete. Exiting.")
                break
            
            # Wait before next scan in watch mode
            logger.info("Waiting 60 seconds before next scan...")
            time.sleep(60)
            
        except KeyboardInterrupt:
            logger.info("Received interrupt signal. Shutting down...")
            break
        except Exception as e:
            logger.error(f"Unexpected error: {str(e)}")
            if not watch_mode:
                break
            time.sleep(60)
    
    logger.info("Unrar Tool Stopped")

if __name__ == "__main__":
    main()

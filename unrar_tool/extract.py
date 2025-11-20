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
        cmd = ['unrar', 'x', '-o+', '-y', str(rar_file), str(target_dir) + '/']
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            logger.info(f"Successfully extracted {rar_file}")
            
            if delete_after:
                os.remove(rar_file)
                logger.info(f"Deleted {rar_file} after extraction")
            
            return True
        else:
            logger.error(f"Failed to extract {rar_file}: {result.stderr}")
            return False
            
    except Exception as e:
        logger.error(f"Error extracting {rar_file}: {str(e)}")
        return False

def scan_for_rar_files(source_path):
    """Scan directory for RAR files."""
    rar_files = []
    
    try:
        for root, dirs, files in os.walk(source_path):
            for file in files:
                if file.lower().endswith('.rar'):
                    rar_files.append(os.path.join(root, file))
    except Exception as e:
        logger.error(f"Error scanning directory: {str(e)}")
    
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
    
    # Test if unrar is available
    try:
        result = subprocess.run(['unrar'], capture_output=True, text=True)
        logger.info("unrar is available for extraction")
    except Exception as e:
        logger.error("unrar is not available! Cannot extract files.")
        sys.exit(1)
    
    processed_files = set()
    
    while True:
        try:
            # Find all RAR files
            rar_files = scan_for_rar_files(source_path)
            
            # Process new RAR files
            for rar_file in rar_files:
                if rar_file not in processed_files:
                    logger.info(f"Found new RAR file: {rar_file}")
                    
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
            time.sleep(60)  # Check every minute
            
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

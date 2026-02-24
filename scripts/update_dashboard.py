#!/usr/bin/env python3
"""
Universal Dashboard Updater
Updates any dashboard (ai, fintech, edutech, security) with CLI arguments
"""

import sys
import argparse
from pathlib import Path

# Import the AI dashboard updater class
sys.path.insert(0, str(Path(__file__).parent))
from update_ai_dashboard import DashboardUpdater

def main():
    parser = argparse.ArgumentParser(description='Update dashboard from data sources')
    parser.add_argument('--config', required=True, help='Path to sources.yaml')
    parser.add_argument('--dashboard', required=True, help='Dashboard name (ai, fintech, edutech, security)')

    args = parser.parse_args()

    # Update the dashboard using the specified config
    updater = DashboardUpdater(config_path=args.config)
    updater.run()

if __name__ == '__main__':
    main()

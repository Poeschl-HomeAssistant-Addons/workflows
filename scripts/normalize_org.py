#!/usr/bin/env python3
import argparse
import logging
import sys
from typing import Dict, Any

import yaml
from github import Github
from github.Auth import Token
from github.Repository import Repository

"""
This script aligns some settings of the addon repositories as well as the corresponding GitHub packages.
"""

REPO_TOPICS = ["home-assistant-addon", "hacktoberfest"]


def read_addons_file(file_path) -> Dict[str, Any]:
    try:
        with open(file_path, 'r') as file:
            return yaml.safe_load(file.read())
    except FileNotFoundError:
        logging.error(f"Error: File not found - {file_path}")
        sys.exit(1)
    except Exception as e:
        logging.error(f"Error reading file: {e}")
        sys.exit(1)


def normalize_addon_repository(repo: Repository):
    if repo.has_wiki:
        repo.edit(has_wiki=False)
        logging.info("Changed Wiki to false")

    if repo.has_projects:
        repo.edit(has_projects=False)
        logging.info("Changed Projects to false")

    if repo.has_discussions:
        repo.edit(has_discussions=False)
        logging.info("Changed Discussions to false")

    if repo.visibility != 'public':
        repo.edit(visibility='public')
        logging.info("Changed visibility to public")

    if not repo.delete_branch_on_merge:
        repo.edit(delete_branch_on_merge=True)
        logging.info("Changed delete_branch_on_merge to true")

    if repo.get_topics().sort() != REPO_TOPICS.sort():
        repo.replace_topics(REPO_TOPICS)
        logging.info("Changed topics to %s", REPO_TOPICS)


def normalize_packages():
    pass


def main(token: str, addon_file_path: str):
    addons_data = read_addons_file(addon_file_path)
    github = Github(auth=Token(token))

    for key, addon in addons_data['addons'].items():
        logging.info(f"Processing addon {key}")
        normalize_addon_repository(github.get_repo(addon['repository']))
        logging.info("------------------------------------------")

    # TODO: Switch all packages to public. Not possible with this python package, switch to ghapi!


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO,
                        format="%(asctime)s %(levelname)s [%(name)s] %(message)s",
                        datefmt="%Y-%m-%d %H:%M:%S",
                        stream=sys.stdout)

    parser = argparse.ArgumentParser(description="Normalizes all addon repositories of the addon org")
    parser.add_argument("addonsfile", help="Path to the addons file")
    parser.add_argument("token", help="GitHub personal access token")

    args = parser.parse_args()

    exit(main(args.token, args.addonsfile))

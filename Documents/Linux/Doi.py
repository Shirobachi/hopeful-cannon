#!/usr/bin/env python3
import os
from urllib import request
try:
  import click
except:
  os.system("pip3 install click")
  print("Some dependencies was missing. Please run the script again.")
  exit(1)
########## Functions ##########

@click.group(help="Doi is your personal assistant. Type --help for more information.")
def all_commands():
  pass

########## Core ##########

def load_vars():
  os.system(". ~/.env")


def read_env(env):
  load_vars()
  return os.environ[env]

def save_env(env, value):
  os.system(f"sed -i '/{env}/d' ~/.env")
  os.system(f"echo export {env}={value} >> ~/.env")
  load_vars()

########## BACKUP Command group ##########

@click.group(help="All commands what can be helpful with bare repo backup.")
def backup():
  pass

@backup.command(help="This command will let you transform your backup b/w master and slave mode.")
@click.argument("mode", type=click.Choice(["master", "slave"], case_sensitive=False), required=True)
def transform(mode):
  save_env("DOI_BACKUP_MASTER", 'true' if mode == "master" else 'false')
  print(f"Backup mode was changed to {mode}.")

########## TOKEN Command group ##########

@click.group(help="Manage your tokens.")
def token():
  pass

@token.command(help="Set your github token.")
@click.option("--token", "-t", required=True, type=str, prompt=True, hide_input=True)
def gh(token):
  save_env("DOI_TOKEN_GH", token)
  print("Token saved.")

########## Main ##########

all_commands.add_command(backup)
all_commands.add_command(token)
if __name__ == "__main__":
  all_commands()
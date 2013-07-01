#! /usr/bin/env python

__authors__ = [
  '"Jean-Charles Delay" <delay@adacore.com>',
]


import os
import sys
import time

from getopt import getopt

from os.path import basename
from os.path import dirname
from os.path import join
from os.path import splitext

from subprocess import PIPE
from subprocess import Popen

from signal import SIGINT
from signal import signal


# Timeout limit in second for each test.
TIMEOUT = 3
MI_CHECK = 'mi_check'
LIBGDBMI = 'libgdbmi.a'

# Some constants about test case files.
CASES_SUBPATH = 'cases'
CASES_EXTENTION = '.mi'
UTILS_CASES_SUFFIX = '_test.adb'

# Colors used in output.
BLUE = '\x1b[1;34m'
GREEN = '\x1b[0;32m'
NC = '\x1b[0m'
RED = '\x1b[0;31m'
YELLOW = '\x1b[1;33m'


# Global context map.
global _ctx
_ctx = {
  'verbose' : False,
  'parser' : True,
  'utils' : True,
  'categories' : [],
  'use-valgrind' : False
}


def sigint_handler(signal, frame):
  sys.stdout.write('%sSignal SIGINT caught, exiting...%s' % (os.linesep, os.linesep))
  sys.exit(1)


def test_valgrind():
  (ecode, stdout, stderr) = invoke(['valgrind', '--version'])
  return ecode is not None and ecode == 0


class CmdlineError(Exception):
  """Base exception for all exceptions raised in Cmdline."""
  pass


class Cmdline(object):
  def __init__(self, argv):
    self.__argv = argv

  def usage(self):
    print '''usage: python run_tests.py [-hv] [-c <category> [-c <category>]...]
                           [--parser] [--utils] [--with-valgrind]'''

  def parse(self):
    try:
      (opts, args) = getopt(self.__argv, 'hvc:',
                            ['help', 'verbose', 'category=','parser','utils',
                             'with-valgrind'])
    except getopt.GetoptError as error:
      raise CmdlineError(str(error))
    global _ctx
    for (opt, arg) in opts:
      if opt in ('-h', '--help'):
        self.usage()
        sys.exit(0)
      elif opt in ('-v', '--verbose'):
        _ctx['verbose'] = True
      elif opt in ('-c', '--category'):
        _ctx['categories'].append(arg)
      elif opt in ('--parser'):
        _ctx['parser'] = True
        _ctx['utils'] = False
      elif opt in ('--utils'):
        _ctx['utils'] = True
        _ctx['parser'] = False
      elif opt in ('--with-valgrind'):
        _ctx['use-valgrind'] = True


def build(fname, root_dir):
  """Build an Ada source file.

  Builds the given file located by FNAME and returns the path to the resulting
  binary.
  """

  target = join(root_dir, 'obj', splitext(basename(fname))[0])
  argv = ['gnatmake', '-gnat05', '-gnatyg', '-gnatwae', '-I%s/src' % root_dir,
          '-L%s/lib' % root_dir, '-D', '%s/obj' % root_dir, '-o', target, fname]
  process = Popen(argv, stdout=PIPE, stderr=PIPE)
  (stdout, stderr) = process.communicate()
  if process.returncode != 0:
    return (None, stdout, stderr)

  return (target, stdout, stderr)


def invoke(argv, valgrind=False):
  """Execute a process.

  Executes a new process using the given ARGV and returns a tuple containing
  the process exit code, standard output and error output.
  """

  ecode = None
  (stdout, stderr) = (None, None)
  if valgrind:
    argv = ['valgrind', '--leak-check=full', '--error-exitcode=1'] + argv
  # Runs the process.
  process = Popen(argv, stdout=PIPE, stderr=PIPE)
  # Wait for completion or for timeout.
  start = time.time()
  while time.time() - start < TIMEOUT:
    ecode = process.poll()
    if ecode is not None:
      break
    time.sleep(0.05)
  if ecode is not None:
    (stdout, stderr) = process.communicate()
  else:
    # The process has timed out, so we kill it.
    process.terminate()
  # ECODE is None if the process timed out.
  return (ecode, stdout, stderr)


class TestDriverError(Exception):
  """Base exception for all exceptions raised in TestDriver."""
  pass


class MiParserTestDriver(object):

  """Main class to collect and run test cases.

  Attributes:
    __test_dir:   This is the gdbmi/tests/ directory path, provided to the
                  constructor of this class (and corresponding to the root
                  directory of this script).
    __test_bin:   The binary to invoke to test the parser by passing the mi
                  files as command line argument.
    __categories: A list of test categories, corresponding to a leaf directory.
    __cases:      A dictionary associating list of mi files to their category.
  """

  def __init__(self, test_dir):
    """Inits TestDriver with command line arguments (stripped of argv[0]).

    Args:
      test_dir: This is the gdbmi/tests/ directory path (i.e. this script's
                root directory).
    """
    self.__test_dir = test_dir
    self.__test_bin = join(test_dir, 'obj', MI_CHECK)
    self.__categories = []
    self.__cases = {}

  def _findLeafDirs(self, base_dir):
    """Protected method that returns a list of all leaf directories in the
    filesystem from the specified base_dir, e.g.

        base_dir
        |-- dir1
        |-- dir2
        |   |-- dir4
        |   |-- dir5
        |-- dir3

    Args:
      The root directory from where starting the search. Defaulted to the
      current working directory.

    Returns:
      A list of BASE_DIR leaves [ "dir1", "dir4", "dir5", "dir3" ]
    """

    # Tests whether the directory is a leaf or if it contains subdirectories.
    found  = False
    for item in os.listdir(base_dir):
      directory = join(base_dir, item)
      if os.path.isdir(directory) and item != '.svn':
        found = True
        break
    # Recursion stop condition, the directory is a leaf, so returns it.
    if not found:
      return [base_dir]

    # Directory has subdirectories. Collects them.
    leaves = []
    for item in os.listdir(base_dir):
      directory = join(base_dir, item)
      if os.path.isdir(directory) and item != '.svn':
        leaves = leaves + self._findLeafDirs(directory)
    return leaves

  def _findMiFiles(self, search_path, categories=None):
    """Protected method to find the mi tests file on filesystem.

    This function looks for the .mi tests files, eventually filtering depending
    in the category if specified.

    Returns a dict with a entry for each available category and a corresponding
    list of absolute path to the .mi files.
    """

    # Compute search path value.
    if not os.path.exists(search_path) or not os.path.isdir(search_path):
      raise TestDriverError('cannot find test cases directory')
    # Find leaf directories.
    leaves = self._findLeafDirs(search_path)
    if categories and len(categories):
      leaves = filter(lambda x: os.path.basename(x) in categories, leaves);
    # Find '.mi' files.
    files = {}
    for leaf in leaves:
      item = os.path.basename(leaf)
      files[item] = []
      for f in os.listdir(leaf):
        p = join(leaf, f)
        if os.path.isfile(p) and os.path.splitext(p)[1] == CASES_EXTENTION:
          files[item].append(p)
    return files

  def load(self):
    """Find and load test categories and cases.

    Find the list of available categories and their associated test cases, and
    store them in the class attributes.
    """

    if not os.path.exists(self.__test_bin):
      print('test executable does not exists')
      sys.exit(1)
    if not os.access(self.__test_bin, os.X_OK):
      print('cannot run test executable: permission denied')
      sys.exit(1)
    self.__test_dir = join(self.__test_dir, CASES_SUBPATH)
    self.__cases = self._findMiFiles(self.__test_dir, _ctx['categories'])
    return 1

  def run(self):
    total = 0
    errors = 0
    for key in self.__cases:
      if self.__cases[key] is None or not len(self.__cases[key]):
        print('Warn: No test case for category %s' % key)
        continue
      idx = 0
      suberrors = 0
      subtotal = len(self.__cases[key])
      global _ctx
      for case in self.__cases[key]:
        progress = idx * 100 / subtotal
        if _ctx['verbose']:
          sys.stdout.write('%s(%*d/%d)%s [%sExecute%s] %s\r' % (BLUE,
                           len(str(subtotal)), idx + 1, subtotal, NC, YELLOW,
                           NC, case.replace(self.__test_dir, '')[1:]))
        else:
          sys.stdout.write('Running: %.1f%% (%d/%d) [%s]\r' % (progress, idx,
                                                               subtotal, key))
        sys.stdout.flush()
        idx += 1
        total += 1
        (ecode, stdout, stderr) = invoke([self.__test_bin, case], valgrind=_ctx['use-valgrind'])
        if ecode is None or ecode != 0:
          suberrors = suberrors + 1
          if _ctx['verbose']:
            sys.stdout.write('%s(%*d/%d)%s [%sFailure%s] %s' % (BLUE,
                             len(str(subtotal)), idx, subtotal, NC, RED, NC,
                             case.replace(self.__test_dir, '')[1:]))
        else:
          if _ctx['verbose']:
            sys.stdout.write('%s(%*d/%d)%s [%sSuccess%s] %s' % (BLUE,
                             len(str(subtotal)), idx, subtotal, NC, GREEN, NC,
                             case.replace(self.__test_dir, '')[1:]))
        if _ctx['verbose']: sys.stdout.write(os.linesep)
      assert(idx == subtotal)
      if not _ctx['verbose']:
        print('Running: 100.0%% (%d/%d) [%s]' % (idx, subtotal, key))
      else:
        if not suberrors:
          print('%sSuccessfully passed %d test(s)%s' % (GREEN, subtotal, NC))
        else:
          print('%sFailed %d test(s) among %d%s' % (RED, suberrors, subtotal, NC))
      errors = errors + suberrors
    if not errors:
      print('%sSuccessfully passed all %d test(s)%s' % (GREEN, total, NC))
    else:
      print('%sFailed %d test(s) among all %d%s' % (RED, errors, total, NC))
    return errors


class MiUtilsTestDriver(object):

  """Main class to collect and run test cases.

  Attributes:
    __root_dir: This is the gdbmi/ directory path, computed from the given
                testdir which is the gdbmi/tests/ directory (the root directory
                of this script).
    __test_dir: This is the gdbmi/tests/ directory path, provided to the
                constructor of this class (and corresponding to the root
                directory of this script).
    __test_lib: This is the libgdbmi.a path, computed from __test_dir
                directory.
    __cases:    This is a list of test cases handled by this driver and filled
                up by the _findTestFiles() method.
  """

  def __init__(self, test_dir):
    """Inits MiUtilsTestDriver.

    Args:
      test_dir: This is the gdbmi/tests/ directory path (i.e. this script's
                root directory).
    """
    self.__root_dir = dirname(test_dir)
    self.__test_dir = test_dir
    self.__test_lib = join(test_dir, '..', 'lib', LIBGDBMI)
    self.__cases = []

  def _findTestFiles(self, search_path):
    """Protected method to find the mi-utils tests file on filesystem.

    This function looks for the tests files matching the UTILS_CASES_SUFFIX
    suffix.

    Returns a list corresponding to the list of absolute path to the test
    files.
    """

    # Compute search path value.
    if not os.path.exists(search_path) or not os.path.isdir(search_path):
      raise TestDriverError('cannot find test cases directory')
    # Find test files.
    files = []
    for f in os.listdir(search_path):
      p = os.path.join(search_path, f)
      if os.path.isfile(p) and p.endswith(UTILS_CASES_SUFFIX):
        files.append(p)
    return files

  def load(self):
    """Find and load test cases. """

    if not os.path.exists(self.__test_lib):
      print('libgdbmi.a has not been built')
      sys.exit(1)
    self.__test_dir = os.path.join(self.__test_dir, 'src', 'utils')
    self.__cases = self._findTestFiles(self.__test_dir)
    return 1

  def run(self):
    total = len(self.__cases)
    errors = 0
    idx = 0
    global _ctx

    for case in self.__cases:
      progress = idx * 100 / total
      if _ctx['verbose']:
        sys.stdout.write('%s(%*d/%d)%s [%sCompile%s] %s\r' % (BLUE,
                         len(str(total)), idx + 1, total, NC, YELLOW, NC,
                         case.replace(self.__test_dir, '')[1:]))
      else:
        sys.stdout.write('Running: %.1f%% (%d/%d) [MI.Utils tests]\r'
                         % (progress, idx, total))
      sys.stdout.flush()
      (binary, stdout, stderr) = build(case, self.__root_dir)
      if binary is None:
        sys.stdout.write(os.linesep)
        print >>sys.stderr, '%sFAIL%s: failed to build test case %s:' % (RED, NC, case)
        print >>sys.stderr, stdout
        print >>sys.stderr, '%s%s%s' % (RED, stderr, NC)
      elif _ctx['verbose']:
        sys.stdout.write('%s(%*d/%d)%s [%sExecute%s] %s\r' % (BLUE,
                         len(str(total)), idx + 1, total, NC, YELLOW, NC,
                         case.replace(self.__test_dir, '')[1:]))
        sys.stdout.flush()
      idx += 1
      if binary:
        (ecode, stdout, stderr) = invoke([binary], valgrind=_ctx['use-valgrind'])
      if binary is None:
        errors = errors + 1
        continue
      if ecode is None or ecode != 0:
        errors = errors + 1
        if _ctx['verbose']:
          sys.stdout.write('%s(%*d/%d)%s [%sFailure%s] %s' % (BLUE,
                           len(str(total)), idx, total, NC, RED, NC,
                           case.replace(self.__test_dir, '')[1:]))
      else:
        if _ctx['verbose']:
          sys.stdout.write('%s(%*d/%d)%s [%sSuccess%s] %s' % (BLUE,
                           len(str(total)), idx, total, NC, GREEN, NC,
                           case.replace(self.__test_dir, '')[1:]))
      if _ctx['verbose']: sys.stdout.write(os.linesep)

    assert(idx == total)

    if not _ctx['verbose']:
      print('Running: 100.0%% (%d/%d) [Mi.Utils tests]' % (idx, total))

    if not errors:
      print('%sSuccessfully passed all %d test(s)%s' % (GREEN, total, NC))
    else:
      print('%sFailed %d test(s) among all %d%s' % (RED, errors, total, NC))

    return errors


if __name__ == '__main__':
  path = os.path.split(sys.argv[0])
  # Register SIGINT handler.
  signal(SIGINT, sigint_handler)
  # Compute test directory path.
  test_dir = os.path.abspath(path[0])
  # Parse the command line.
  Cmdline(sys.argv[1:]).parse()

  if _ctx['use-valgrind']:
    if not test_valgrind():
      print 'valgrind not in the PATH'
      sys.exit(1)

  errors = 0

  if _ctx['parser']:
    # Loading and running parser test driver.
    driver = MiParserTestDriver(test_dir)
    driver.load()
    errors += driver.run()

  if _ctx['utils']:
    # Loading and running utils test driver.
    driver = MiUtilsTestDriver(test_dir)
    driver.load()
    errors += driver.run()

  sys.exit(errors)

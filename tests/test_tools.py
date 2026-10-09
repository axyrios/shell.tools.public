import json
import os
import pathlib
import shutil
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class ComposeTests(unittest.TestCase):
    def exercise(self, failure=''):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            docker = root / 'docker'
            docker.write_text('#!/usr/bin/env python3\nimport sys,os,json\na=sys.argv[1:]\nwith open(os.environ["CALLS"],"a") as f:f.write(json.dumps(a)+"\\n")\nif os.environ.get("FAIL") and os.environ["FAIL"] in a:sys.exit(9)\n')
            docker.chmod(0o755)
            env = os.environ.copy()
            env.update(PATH=str(root)+os.pathsep+env['PATH'], CALLS=str(root/'calls'), FAIL=failure)
            process = subprocess.run(['bash', str(ROOT/'tools.docker-compose.update.simple.sh'), '--project-dir', directory, '--project-name', 'sample', '--service', 'grist'], env=env, capture_output=True, text=True)
            calls = [json.loads(line) for line in (root/'calls').read_text().splitlines()]
            return process, calls

    def test_targets_only_selected_service_without_down_or_prune(self):
        process, calls = self.exercise()
        self.assertEqual(process.returncode, 0, process.stderr)
        update = next(call for call in calls if 'up' in call)
        self.assertIn('--no-deps', update)
        self.assertEqual(update[-1], 'grist')
        self.assertFalse(any(word in call for call in calls for word in ['down', 'prune', '--remove-orphans', 'build']))

    def test_pull_failure_preserves_running_container(self):
        process, calls = self.exercise('pull')
        self.assertNotEqual(process.returncode, 0)
        self.assertFalse(any('up' in call or 'down' in call for call in calls))

    def test_invalid_config_prevents_pull_and_up(self):
        process, calls = self.exercise('config')
        self.assertNotEqual(process.returncode, 0)
        self.assertFalse(any('pull' in call or 'up' in call for call in calls))


class GitTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.base = pathlib.Path(self.temp.name)
        self.remote = self.base/'remote.git'
        self.repo = self.base/'work'
        self.call('init', '--bare', str(self.remote), directory=self.base)
        self.call('init', '-b', 'main', str(self.repo), directory=self.base)
        self.call('config', 'user.name', 'Tests')
        self.call('config', 'user.email', 'tests@example.invalid')
        (self.repo/'docker-compose.yml').write_text('services: {}\n')
        (self.repo/'.gitignore').write_text('.env\npersist/\n')
        self.call('add', '.')
        self.call('commit', '-m', 'Initial')
        self.call('remote', 'add', 'origin', str(self.remote))
        self.call('push', '-u', 'origin', 'main')

    def tearDown(self):
        self.temp.cleanup()

    def call(self, *args, directory=None):
        return subprocess.check_output(['git', '-C', str(directory or self.repo), *args], stderr=subprocess.DEVNULL, text=True).strip()

    def sync(self, *args):
        return subprocess.run(['bash', str(ROOT/'tools.gitpush.simple.sh'), '--repo', str(self.repo), *args], capture_output=True, text=True)

    def test_modified_config_and_repeat_do_not_create_extra_commits(self):
        (self.repo/'docker-compose.yml').write_text('services: {grist: {image: example}}\n')
        (self.repo/'.env').write_text('SECRET=local\n')
        self.assertEqual(self.sync().returncode, 0)
        revision = self.call('rev-parse', 'HEAD')
        self.assertEqual(self.sync().returncode, 0)
        self.assertEqual(self.call('rev-parse', 'HEAD'), revision)
        self.assertNotIn('.env', self.call('ls-files').splitlines())

    def test_remote_change_rebased_without_force(self):
        other = self.base/'other'
        self.call('clone', '-b', 'main', str(self.remote), str(other), directory=self.base)
        self.call('config', 'user.name', 'Other', directory=other)
        self.call('config', 'user.email', 'other@example.invalid', directory=other)
        (other/'README.md').write_text('Remote change\n')
        self.call('add', 'README.md', directory=other)
        self.call('commit', '-m', 'Remote', directory=other)
        self.call('push', directory=other)
        (self.repo/'docker-compose.yml').write_text('services: {grist: {image: new}}\n')
        process = self.sync()
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertTrue((self.repo/'README.md').exists())
        self.assertEqual(self.call('rev-parse', 'HEAD'), self.call('rev-parse', 'origin/main'))

    def test_secret_rejected_before_publication(self):
        (self.repo/'leak.txt').write_text('value=' + 'gh' + 'p_' + 'A'*36 + '\n')
        revision = self.call('rev-parse', 'HEAD')
        process = self.sync('--include', 'leak.txt')
        self.assertNotEqual(process.returncode, 0)
        self.assertEqual(self.call('rev-parse', 'HEAD'), revision)
        self.assertEqual(self.call('rev-parse', 'origin/main'), revision)

    def test_initial_empty_remote_supported(self):
        second = self.base/'empty.git'
        self.call('init', '--bare', str(second), directory=self.base)
        self.call('remote', 'add', 'empty', str(second))
        # Initial publication is explicit, prior to scheduled synchronization.
        self.call('push', '-u', 'empty', 'main')
        self.assertEqual(self.sync('--remote', 'empty').returncode, 0)


if __name__ == '__main__':
    unittest.main()

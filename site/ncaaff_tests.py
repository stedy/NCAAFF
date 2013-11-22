import os
import unittest
import ncaaff
import tempfile

class NCAAFFTestCase(unittest.TestCase):
    def setup(self):
        """Make test database before each test"""
        self.db_fd, ncaaff.app.config['DATABASE'] = tempfile.mkstemp()
        ncaaff.app.config['TESTING'] = True
        self.app = ncaaff.app.test_client()
        ncaaff.init_db()

    def teardown(self):
        os.close(self.db_fd)
        os.unlink(ncaaff.app.config['DATABASE'])

    def test_allconf(self):
        rv = self.app.post('/')
        assert b'No Entries in here so far' not in rv.data

if __name__ == "__main__":
    unittest.main()

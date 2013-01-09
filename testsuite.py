#!/usr/bin/python
#
# Copyright (c) SAS Institute Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


import sys
from testrunner import suite
from rmake_test import resources


class Suite(suite.TestSuite):
    testsuite_module = sys.modules[__name__]
    topLevelStrip = 0

    def getCoverageDirs(self, handler, environ):
        return [
                resources.get_path('rmake'),
                resources.get_path('rmake_plugins'),
                ]

    def sortTests(self, tests):
        order = {'smoketest': 0, 
                 'unit_test' :1,
                 'functionaltest':2}
        maxNum = len(order)
        tests = [ (test, test.index('test')) for test in tests]
        tests = sorted((order.get(test[:index+4], maxNum), test)
                       for (test, index) in tests)
        tests = [ x[1] for x in tests if x[1].startswith('rmake_test') ]
        return tests


if __name__ == '__main__':
    Suite().run()

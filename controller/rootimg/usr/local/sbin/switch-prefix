#!/bin/env python

import re
import subprocess
import sys

class Node():
    """A trie to find the longest most common prefix from a set of strings"""
    def __init__(self, value=None):
        self.children = {}
        self.value = value
        self.weight = 0

    def insert(self, key, value):
        """insert an element into the trie"""
        node = self
        for i, ch in enumerate(key):
            if ch in node.children:
                node = node.children[ch]
            else:
                node.children[ch] = Node()
                node = node.children[ch]
            node.weight += 1
        node.value = value
    
    def find(self, key):
        """find an element in this trie"""
        node = self
        for char in key:
            if char not in node.children:
                return None
            else:
                node = node.children[char]
        return node.value

    def allitems(self, lineage = ''):
        """return all the keys in this trie"""
        for ch in self.children:
            node = self.children[ch]
            yield (lineage + ch, node)
            for key in node.allitems(lineage + ch):
                yield key

    def allitems(self, lineage = ''):
        """return all the keys in this trie"""
        stack = []
        stack.append((lineage, self))

        while stack:
            lineage, node = stack.pop()
            yield (lineage, node)
            for child in node.children:
                stack.append((lineage + child, node.children[child]))

    def lcp(self):
        """find the longest most common prefix"""
        best = 0
        prefix = ''
        for key, node in self.allitems():
            weight = node.weight
            # A bit hackish, but we test for the
            # length of the prefix, the number of strings matched
            # and we make sure only digits follow after
            if len(key) * weight > best and \
               all(k.isdigit() for k in node.children):
                 best = len(key) * weight
                 prefix = key
        return prefix, best
            
     
if __name__ == '__main__':
    if len(sys.argv) > 1:
        switch = sys.argv[1]
    else:
        switch = 'switch'

    p = re.compile(r'IF-MIB::ifName.(\d+) = STRING: (.*)')

    root = Node()
    for s in subprocess.check_output('snmpwalk -v2c -c public ' +  
        switch  + ' .1.3.6.1.2.1.31.1.1.1.1', shell=True).split('\n'):
        m = p.match(s)
        if m:
	    value, key = m.groups()
	    root.insert(key, value)

    lcp = root.lcp()[0]
    print "Best prefix is", `lcp`
    print "The regex is", `'|%s($1+0)|'` % lcp

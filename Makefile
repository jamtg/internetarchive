.PHONY: docs

VERSION=$(shell grep -m1 __version__ internetarchive/__init__.py | cut -d\' -f2)

init:
	pip install responses==0.5.0 pytest-cov pytest-pep8
	pip install -e .

clean:
	find . -type f -name '*\.pyc' -delete
	find . -type d -name '__pycache__' -delete

pep8-test:
	py.test --pep8 -m pep8 --cov-report term-missing --cov internetarchive

test:
	py.test --pep8 --cov-report term-missing --cov internetarchive

publish:
	git tag -a v$(VERSION) -m 'version $(VERSION)'
	git push --tags
	python setup.py sdist upload
	python setup.py bdist_wheel upload

docs-init:
	pip install -r docs/requirements.txt

docs:
	cd docs && make html
	@echo "\033[95m\n\nBuild successful! View the docs homepage at docs/build/html/index.html.\n\033[0m"

binary:
	# This requires using https://github.com/jjjake/pex which has been hacked for multi-platform support.
	pex . --python python3.7 --python python2 --python-shebang='/usr/bin/env python' --platform=linux-x86_64-cp-37-m -e internetarchive.cli.ia:main -o ia-$(VERSION)-py2.py3-none-any.pex -r pex-requirements.txt # make with py2???
	# Use pex==1.4.0
	#pex . --python python3 --python /usr/bin/python --python-shebang='/usr/bin/env python' --platform=linux-x86_64 --platform=macosx_10_11 -e internetarchive.cli.ia:main -o ia-$(VERSION)-py2.py3-none-any.pex -f wheelhouse/ --no-pypi

publish-binary:
	./ia-$(VERSION)-py2.py3-none-any.pex upload ia-pex ia-$(VERSION)-py2.py3-none-any.pex --no-derive
	./ia-$(VERSION)-py2.py3-none-any.pex upload ia-pex ia-$(VERSION)-py2.py3-none-any.pex --remote-name=ia --no-derive

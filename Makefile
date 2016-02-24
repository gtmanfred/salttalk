SHELL := /bin/zsh
BUILD_DIR=$(HOME)/github/salttalk
PYTHON=$(HOME)/.pyenv/shims/python

build: revelator link_reveal build_slides

revelator:
	if test -d revelator; then \
		echo "-------- Checking for latest version of Revelator --------"; \
		pushd revelator; \
		git pull; \
		popd; \
	else \
		echo "-------- Downloading Revelator --------"; \
		git submodule update --init; \
	fi

link_reveal:
	if ! test -s reveal_js_261; then \
		ln -fs revelator/reveal_js_261; \
	fi


build_slides:
	echo "-------- Looping over folders --------"; \
	for i in meetup/*(/) ; do \
		echo -------- Syntax Check $$i --------; \
		$(PYTHON) $(BUILD_DIR)/syntax_check.py $(BUILD_DIR)/$$i/*.yml; \
		echo -------- Creating output folder for $$i --------; \
		mkdir -p output/$$i; \
		echo -------- Build Single on $$i --------; \
		$(PYTHON) $(BUILD_DIR)/build_single.py $(BUILD_DIR)/$$i > $$i_comp.yml; \
		echo -------- Generating Slides on $$i --------; \
		$(PYTHON) revelator/write_it $$i_comp.yml output/$$i; \
    	echo "-------- Hacking stylesheets for $$i --------"; \
		sed -ie '32s/#eeeeee/#000000/' output/$$i/css/theme/default.css; \
		sed -ie '49s/#eeeeee/#000000/' output/$$i/css/theme/default.css; \
    done

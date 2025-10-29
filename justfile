default:
    @just --choose

format:
    @find . -name "*.sh" -exec shfmt -w -i 4 -ci {} \;


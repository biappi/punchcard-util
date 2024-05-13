docker run -it -v `pwd`:/home -w /home --rm swift swift build -c release

echo "executable is in .build/release/pcard"

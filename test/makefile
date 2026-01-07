.PHONY: all clean

all:
	../prueba.sh --graph
	../prueba.sh --burndown > ./prueba.burndown.txt
	../prueba.sh --summary  > ./prueba.summary.txt

clean:
	rm -f *.txt *.svg *.png *.jpg *.jpeg *~


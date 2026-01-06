.PHONY: all clean

all:
	../prueba.sh --graph
	../prueba.sh --burndown > ./prueba.burndown.txt
	../prueba.sh --summary  > ./prueba.summary.txt
	../prueba.sh --status   > ./prueba.status.txt

clean:
	rm -f prueba.*.txt *.svg *.png *.jpg *.jpeg *~


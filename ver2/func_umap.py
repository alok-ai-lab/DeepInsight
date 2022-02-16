#! /usr/bin/python

import numpy 
import sys
import umap

# run with python input_file.txt > output_file.txt

dataarray = numpy.loadtxt("data_in.txt",delimiter="\t")
embedding = umap.UMAP().fit_transform(dataarray)
numpy.savetxt("data_out.txt",embedding,delimiter="\t")

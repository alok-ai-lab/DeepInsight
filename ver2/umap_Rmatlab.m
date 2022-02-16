function data_out = umap_Rmatlab(data_in)
% data_in = #sample x #feature

dlmwrite('data_inR.txt',data_in,'delimiter','\t','precision',4);
unix('Rscript func_umap.R data_inR.txt > data_outR.txt');
%unix('python ./func_umap.py');
data_out=load('data_outR.txt');

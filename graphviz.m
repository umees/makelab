function graphviz(mfname,opts,tmpdir)
% function graphviz(mfname,opts)
% 
% Uses the graphviz package to view makefile dependencies.
%
% in:
%	mfname; makefile name, optional, default 'makefile'.
%	opts; command line options, default none
%	tmpdir; temporary file storage, default '/tmp'
%
% out:
%	nothing
%

	if nargin < 3; tmpdir = '/tmp'; end
	if nargin < 2; opts = ''; end
	if nargin < 1; mfname = 'makefile'; end
	eval(['global ', mfname, ';'])
	mf = eval(mfname);

	fh = fopen([tmpdir, '/makelab.gv'],'w');
	fprintf(fh,'digraph %s {\n\trankdir=LR\n',mfname);

	fnames = {};
	targets = fieldnames(mf);

	for i = 1:length(targets)
		target = targets{i};
		tptr = [mfname, '.', target];
		deps = eval([tptr '.deps'],'{}');
		fdeps = eval([tptr '.fdeps'],'{}');
		for j = 1:length(deps)
			fprintf(fh,'\t%s -> %s;\n',deps{j},target);
		end
		for j = 1:length(fdeps)
			fprintf(fh,'\t%s -> %s [style=dotted];\n',fixfn(fdeps{j}),target);
			fnames = addifunique(fnames,fdeps{j});
		end
		% To have files on the same rank as their deps:
		%fprintf(fh,'\t{rank=same; %s',target);
		%for j = 1:length(fdeps)
		%	fprintf(fh,' %s',fixfn(fdeps{j}));
		%end
		%fprintf(fh,'};\n');
	end
	% Uncomment this and (*) for a cluster of files on the side
	%fprintf(fh,'\tsubgraph clusterfiles {\n');
	for i = 1:length(fnames)
		fprintf(fh,'\t\t%s [label="%s",shape=note];\n',fixfn(fnames{i}),fnames{i});
	end
	%fprintf(fh,'\t}\n}\n'); % (*)
	system(sprintf('dot %s/makelab.gv -Tps -o%s/makelab.ps %s',tmpdir,tmpdir,opts));
	system(sprintf('gv %s/makelab.ps',tmpdir));
	dummy = 0;

function cnew = addifunique(c,k)
	cnew = c;
	for i = 1:length(c)
		if isequal(c{i},k)
			return;
		end
	end
	cnew{length(cnew)+1} = k;

function f = fixfn(x)
	f = x;
	i = find(f == '.');
	f(i) = '_';

% RA 106228
% Rafael Timbo
% Trabalho 3

function normmat = normalize(matrix)
	normmat = 9.0/255.0 * matrix;
end

function [ ht3, bayer ]  = halftone(img)
  [ height,  width ] = size(img);
	% mascara de limiares
	mask3 = [ 6 8 4     ; 1 0 3    ; 5 2  7    ];
	% Replique a mascara para o tamanho da imagem
	mask3 = repmat(mask3,height, width);
	bayermask = [ 0 12 3 15 ;  8 4 11 7 ; 2 14 1 13 ; 10 6 9 5 ];
	bayermask = repmat(bayermask, height, width);
  matrix = normalize(img);
  ht3 = [];
	bayer = [];
	% Expanda cada pixel para o tamanho da mascara
  for i = 1 : height
    line = [];
		bline = [];
    for j = 1 : width
      line  = [ line ; repmat(matrix(i,j),3,3)];
			bline = [ bline ; repmat(matrix(i,j),4,4)];
    end 
    ht3 = [ ht3 ; transpose(line) ];
		bayer = [ bayer ; transpose(bline)];
  end 
	ht3 = ht3 > mask3;
	ht3 = ht3 * 255
	bayer = bayer > bayermask;
	bayer = bayer * 255
end

function g = floydsteinberg(f)
	[height, width] = size(f);
	g = ones(height, width);
	for x = 1 : 1 : height
		if mod(x,2) == 0
			startvalue = width;
			iteration = -1;
			endvalue = 1;
		else
			startvalue = 1;
			iteration = 1;
			endvalue = width;
		end

		for y = startvalue : iteration : endvalue
			if f(x,y) < 128
				g(x,y) = 0;
			else
				g(x,y) = 255;
			end

			erro = f(x,y) - g(x,y) * 255;
			if isindex(x + 1,height)
				f(x + 1, y) = f(x + 1, y) + (7/16) * erro;
				if isindex(y + 1, width)
					f(x + 1, y + 1) = f(x + 1, y + 1) + (1/16) * erro;
				end
			end
			if isindex(y + 1, width)
				f(x, y + 1) = f(x, y + 1) + (5/16) * erro;
				if isindex(x - 1, height)
					f(x - 1, y + 1) = f(x - 1, y + 1) + (3/16) * erro;
				end
			end
			g(x,y)
		end
	end
end

imagefiles = dir('*.pgm');
% itere por todas as imagens
for imgindex = 1:length(imagefiles)
	currentfilename = imagefiles(imgindex).name
	floyd = floydsteinberg(imread(currentfilename))
	[ ht3, bayer ] = halftone(imread(currentfilename))
	imwrite(floyd, strcat('saida/floyd-steinberg_', currentfilename));
	imwrite(ht3, strcat('saida/half-toning3_', currentfilename));
	imwrite(bayer, strcat('saida/bayer_', currentfilename));
end

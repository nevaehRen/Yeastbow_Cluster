function WriteImageJROI(Datacell,Path,Name)

%WriteImageJROI - FUNCTION Read matlab structure into ImageJ ROI.
%
%Usage: WriteImageJROI(Datacell,Path)
%
%This function reads the matlab structure by cell array.
%
%'datacell' contains many cells and every cell is consisted of one matlab
%structure which is the output of another function-'ReadImageJROI'.
%'path' defines the place where the output file is restored in.
%

% -- Check arguments

if (nargin ~= 3)
   disp('*** WriteImageJROI: Incorrect usage');
   help WriteImageJROI;
   return;
end



% -- compute length of the input datacell to decide the output format.
    LengthofDatacell=length(Datacell);

% -- if the length is , the output format is '.roi'.
%     if (isequal(LengthofDatacell,1))
% % %         disp('The output file ia a .roi file');
% -- write the data into file
%         WriteSingleImageJROI(Datacell{1},Path);
% -- if the length is larger than 1, the output format is '.zip'.
%     else if (LengthofDatacell>1)
     if (LengthofDatacell>0)

% % %                 disp('The output file ia a .zip file');
% -- define the path of the new built folder                
                folderpath = [Path,'/',Name];
% -- build a new folder to restore all of the '.roi' file                
                mkdir(folderpath);
% -- define the path of the '.zip' file                 
                zipfilepath = [Path,'/',Name,'.zip'];
% -- write the data into file                
                for i=1:LengthofDatacell
                   WriteSingleImageJROI(Datacell{i},folderpath);
                end
% -- zip the folder as a zipped file                
                zip(zipfilepath,{'*.roi'},folderpath);
% -- delete the folder                
                rmdir(folderpath,'s');
         else
                error('Input data format is wrong');
         end
     end
% end


function WriteSingleImageJROI(Data,Path) 

% WriteSingleImageJROI - FUNCTION write a matlab structure into an ImageJ ROI
%
% Usage: WriteSingleImageJROI(Data,Path) 
%
% This function reads the matlab structure into an ImageJ ROI by binary format.
%
%'data' is a cell array where the function extract information from. 
%'path' is the full path to restore one '.roi' file.
%
%The field '.strType' is guaranteed to exist, and defines the ROI type:
% {'Rectangle','Polygon', 'Freehand',  'NoROI'}.
%
% The field '.strName' is guaranteed to exist, and contains the ROI name (the
% filename minus '.roi').
%
% The field '.vnRectBounds' is guaranteed to exist, and defines the rectangular
% bounds of the ROI: ['nTop', 'nLeft', 'nBottom', 'nRight'].
%
% The field '.nVersion' is guaranteed to exist, and defines the version number
% of the ROI format.
%
% ROI types:
%  Rectangle:
%     .strType = 'Rectangle';
%     .nArcSize         - The arc size of the rectangle's rounded corners
%
%  Polygon:
%     .strType = 'Polygon';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the polygon vertices.  Each row is [nX nY].
%
%  Freehand:
%     .strType = 'Freehand';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the polygon vertices.  Each row is [nX nY].
%
%  NoROI:
%     .strType = 'NoROI';
%
% Additionally, ROIs from later versions (.nVersion >= 218) may have the
% following fields:
%
%     .nStrokeWidth     - The width of the line stroke
%     .nStrokeColor     - The encoded color of the stroke (ImageJ color format)
%     .nFillColor       - The encoded fill color for the ROI (ImageJ color
%                          format)
%
% If the ROI contains text:
%     .strSubtype = 'Text';
%     .nFontSize        - The desired font size
%     .nFontStyle       - The style of the font (unknown format)
%     .strFontName      - The name of the font to render the text with
%     .strText          - A string containing the text

    % -- Check arguments

    if (nargin ~= 2)
       disp('*** WriteSingleImageJROI: Incorrect usage');
       help WriteSingleImageJROI;
       return;
    end
    
    
    % -- define a cell for restore ROI information
    
    % -- fefine filepath for ROI file
    filepath=[Path,'/',Data.strName,'.roi'];
    % -- 定义cell
    Outarray=cell(1,27);
    % -- 预填充cell
    % -- 填充输入输出标识符
    Outarray(1)={char('Iout')};
    % -- 填充version
    Outarray(2)={uint16(Data.nVersion)};
    % -- 填充roi type
    Outarray(3)={uint8(6)};
    % -- 填充wideth and height
    for k=1:4;
        Outarray(3+k)={uint16(Data.vnRectBounds(k))};
    end
    % -- 填充number of coordinates
    Outarray(8)={uint16(0)};
    % -- 填充coordinates of straight line
    Outarray(9:12)={0};
    % -- 填充stroke width
    Outarray(13)={int16(Data.nStrokeWidth)};
    % -- 填充shape roi size
    Outarray(14)={uint32(0)};
    % -- 填充strokecolor
    Outarray(15)={uint32(Data.nStrokeColor)};
    % -- 填充fillcolor
    Outarray(16)={uint32(Data.nFillColor)};
    % -- 填充subtype
    Outarray(17)={int16(0)};
    % -- 填充options
    Outarray(18)={int16(0)};
    % -- 填充arrow style/aspect ratio
    Outarray(19)={uint8(0)};
    % -- 填充arrow head size
    Outarray(20)={int8(0)};
    % -- 填充rounded rect arc size
    Outarray(21)={int16(0)};
    % -- 填充tack posistion
    Outarray(22)={uint32(Data.nPosition)};
    % -- 填充head offset
    Outarray(23)={int32(0)};
    
    % -- 根据输入参数重新填充Outarray的部分cell element
    % -- analysis nTypeID    
    switch Data.strType
        
        % -- 输入ROI类型为Rectangle
        case 'Rectangle'
            nTypeID=1;
            % -- 填充rounded rect arc size
            Outarray(21)={int16(Data.nArcSize)};
            % -- compute head offset
            Offsetvalue = 64;
            % -- 填充head2 elements
            Addbytes=32;
            Add=zeros(1,Addbytes);
            Add(1,10)=8*16;
            Add(1,12)=9;
            Outarray(26) = {Add};
            
        % -- 输入ROI类型为Polygon
        case 'Polygon'
            nTypeID=0;
            % -- 填充number of coordinates
            Outarray(8)={uint16(size(Data.mnCoordinates,1))};
            % -- 填充X,Y coordinates
            coordinates = write_coordinates(Data);   
            Outarray(24) = {coordinates(:,1)};
            Outarray(25) = {coordinates(:,2)};
            % -- compute head offset
            Offsetvalue = 64+2*2*size(Data.mnCoordinates,1);
            % -- 填充head2 elements
            Addbytes=32;
            Add=zeros(1,Addbytes);
            Add(1,10)=8*16+12;
            Add(1,12)=9;
            Outarray(26) = {Add};
            
        % -- 输入ROI类型为Freehand
        case 'Freehand'
            nTypeID=7;
            % -- 填充number of coordinates
            Outarray(8)={uint16(size(Data.mnCoordinates,1))};
            % -- 填充X,Y coordinates
            coordinates = write_coordinates(Data);   
            Outarray(24) = {coordinates(:,1)};
            Outarray(25) = {coordinates(:,2)};
            % -- compute head offset
            Offsetvalue = 64+2*2*size(Data.mnCoordinates,1);
            % -- 填充head2 elements
            Addbytes=32;
            Add=zeros(1,Addbytes);
            Add(1,10)=8*16+3*256;
            Add(1,12)=9*1;
            Outarray(26) = {Add};
            
        % -- 输入ROI类型为NoROI
        case 'NoROI'
            nTypeID=6;
        % -- 其他情况 
        otherwise
          error('WriteImageJROI:FormatError', ...
         '--- WriteImageJROI: The data struct contains an unknown ROI type.');    
    end
    %nTypeID
    Outarray(3)={uint8(nTypeID)};
    %head offset
    Outarray(23)={int32(Offsetvalue)};
    % - 创建文件
    NfidROI = fopen(filepath, 'w', 'ieee-be');
    % - 写入数据到文件
    % - write输入输出标识符
    fwrite(NfidROI,Outarray{1},'*char');
    % - write version
    fwrite(NfidROI,Outarray{2},'uint16');
    % - write roi type
    fwrite(NfidROI,Outarray{3},'uint8');
    % - skip a byte
    fwrite(NfidROI,0,'uint8');
    % - write wideth and height
    fwrite(NfidROI,Outarray{4},'uint16');
    fwrite(NfidROI,Outarray{5},'uint16');
    fwrite(NfidROI,Outarray{6},'uint16');
    fwrite(NfidROI,Outarray{7},'uint16');
    % - write number of coordinates
    fwrite(NfidROI,Outarray{8},'uint16');
    % - write coordinates of straight line
    fwrite(NfidROI,Outarray{9},'float32');
    fwrite(NfidROI,Outarray{10},'float32');
    fwrite(NfidROI,Outarray{11},'float32');
    fwrite(NfidROI,Outarray{12},'float32');
    % - write stroke width
    fwrite(NfidROI,Outarray{13},'int16');
    % - write shape roi size
    fwrite(NfidROI,Outarray{14},'uint32');
    % - write strokecolor
    fwrite(NfidROI,Outarray{15},'uint32');
    % - write fillcolor
    fwrite(NfidROI,Outarray{16},'uint32');
    % - write subtype
    fwrite(NfidROI,Outarray{17},'int16');
    % - write options
    fwrite(NfidROI,Outarray{18},'int16');
    % - write arrow style/aspect ratio
    fwrite(NfidROI,Outarray{19},'uint8');
    % - write arrow head size
    fwrite(NfidROI,Outarray{20},'int8');
    % - write rounded rect arc size
    fwrite(NfidROI,Outarray{21},'int16');
    % - write tack posistion
    fwrite(NfidROI,Outarray{22},'uint32');
    % - write head offset
    fwrite(NfidROI,Outarray{23},'int32');
    % - set file position indicator offset 64 bytes from beginning of file
    fseek(NfidROI,64,'bof');
    % - write X coordinates
    fwrite(NfidROI,Outarray{24},'int16');
    % - write Y coordinates
    fwrite(NfidROI,Outarray{25},'int16');
    % - write head2 elements
    fwrite(NfidROI,Outarray{26},'int16');
    % - 填充roi文件name
    Outarray(27) = {Data.strName};
    % - write roi文件name
    fwrite(NfidROI,Outarray{27},'int16');
%     %test
%     fwrite(NfidROI,-3,'int16');
    % - close the file
    fclose(NfidROI);
    
end
    
    
 function [Coordinates] = write_coordinates(Inputdata)
 
 %write_coordinates - FUNCTION extract a list of X,Y Coordinates from the inputdata
 %
 %Usage:[Array] = write_coordinates(arg)
 %
 % - Check arguments
      
      if (nargin == 0)
         disp('*** write_coordinates: Incorrect usage');
         help write_coordinates;
         return;
      end
      % - extract and convert coordinates
        A=Inputdata.mnCoordinates(:,1)-Inputdata.vnRectBounds(1,2);
        B=Inputdata.mnCoordinates(:,2)-Inputdata.vnRectBounds(1,1);
%       % - Trim at zero
%         A(A<0)=0;
%         B(B<0)=0;
      % - output coordinates
        Coordinates=[A B];
 end



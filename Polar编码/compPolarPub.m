% ************************************************************************
% Copyright: Huawei Technologies Co., Ltd. 2017 All rights reserved.
% File name: compPolarPub.m
% Author: CT HangZhou Alg
% Description:  Decoder compiler
% History: Dec 8th, 2017 Cleaned
%*************************************************************************

inclDirc = [ '-I.'];
% inclDirc = [ '-g'];

eval(['mex ' ' ' inclDirc ' ' './PolarDecoderPCCPub.cpp'])

clear inclDirc

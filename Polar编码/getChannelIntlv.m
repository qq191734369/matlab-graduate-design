function channelIntlv = getChannelIntlv(N,DLUL,PolarParam)
if DLUL==1
    seq = 1:N;
elseif DLUL==0
    if isfield(PolarParam,'Seg')
        N = ceil(N/2);
    end
    
    for P=1:N/2
        value(P)=P*(P+1)/2;
        if value(P)>=N
            break;
        end
    end
    IniMatrix=fliplr(triu(ones(P,P),0)) ;
    SeqMatrix=reshape(1:P*P,P,P);
    SeqMatrix=SeqMatrix';
    for ii=1:P
        for jj=1:P
            if IniMatrix(ii,jj)==1
                IniMatrix(ii,jj)=SeqMatrix(ii,jj);
            end
        end
    end
    BeforeSeq=reshape(IniMatrix,1,P*P);
    PosBeforeSeq=find(BeforeSeq~=0);
    BeSeq=BeforeSeq(PosBeforeSeq);
    [sortseq,seq]=sort(BeSeq);
    kk=1;
    for ii=1:length(seq)
        if seq(ii)<=N
            realSeq(kk)=seq(ii);
            kk=kk+1;
        end
    end
    seq=realSeq;
    
    if N>8192
        warning('38212 SPEC LIMIT Interleaver SIZE to 8192!')
    end
end
channelIntlv = seq;
end
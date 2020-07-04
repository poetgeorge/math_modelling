function [pcaF, pcaM, fcmF, fcmM, scoreF, scoreM] = pca_fcm_score(M, F)
%���������ݽ������ɷַ������������ڵ�һ���ɷ���ͶӰ��Ȼ�����ģ�����࣬�������
%M���������� F��Ů������ һ�д���һ�ˣ�һ�д���һ��ָ��
%pcaM�����ɷַ������ ��������������pVecM, ��ת�����srM, ����ֵeigM����������tsquaredM����Ϣ���ٷ���explainedM��Ԫ���ݾ�ֵ����muM
%fcmM��ģ�������� �����ǣ���׼����ģ���������centreM�������Ⱥ���UM��ÿ���������indexM
%scoreM��ÿ���˵ĵ÷�

%���ݱ�׼��
Ms = zscore(M);
Fs = zscore(F);

%���ɷַ���
[pVecM, srM, eigM, tsquaredM,explainedM,muM] = pca(Ms); 
[pVecF, srF, eigF, tsquaredF,explainedF,muF] = pca(Fs);
Mnew = Ms * pVecM(:, 1); %�����ǰ���һ���ɷ�ͶӰ���������
Fnew = Fs * pVecF(:, 1);
pcaF = {pVecF, srF, eigF, tsquaredF,explainedF,muF};
pcaM = {pVecM, srM, eigM, tsquaredM,explainedM,muM};


%��һ��ִ�к������Ǽ�����Ѿ�����nc��
validXB(1:3) = [1000 1000 1000];
X = Mnew(:,1);
for n = 4:20 %sqrt(size(X,1))
    [cent, U, ob] = fcm(X,n);
    validXB(n) = min(ob)/(size(X,1)*min(pdist(cent).^2));
end
[w,ncM] = min(validXB);
validXB = [];

validXB(1:3) = [1000 1000 1000];
X = Fnew(:,1);
for n = 4:20 %sqrt(size(X,1))
    [cent, U, ob] = fcm(X,n);
    validXB(n) = min(ob)/(size(X,1)*min(pdist(cent).^2));
end
[w,ncF] = min(validXB);
validXB = [];


%ncM = [10 8 8 8];
%ncF = [5 10 9 11];

% UM = {zeros(ncM(1),cM), zeros(ncM(2),cM), zeros(ncM(3),cM), zeros(ncM(4),cM)};
% centreM = {zeros(1,ncM(1)), zeros(1,ncM(2)), zeros(1,ncM(3)), zeros(1,ncM(4))};
% indexM = {zeros(1,cM), zeros(1,cM), zeros(1,cM), zeros(1,cM)};

cM = size(Mnew, 1);
cF = size(Fnew, 1);
[centreM, UM] = fcm(Mnew(:,1), ncM); %ģ������
for j = 1:cM
    [tmp,indexM(j)] = max(UM(:,j)); %ȷ��ÿ�������������
end
for j = 1:ncM %���
    top = min(3, max(Mnew(indexM==j,1)));
    bottom = max(-3, min(Mnew(indexM==j,1)));
    intv(j) = top - bottom;
end
interval = 0.5 * min(intv); 
bottom = max(-3, min(Mnew(:,1)));
top = min(3, max(Mnew(:,1)));
level = 70 * interval /(top-bottom);
for j = 1:cM
    scoreM(j) = 30 + (Mnew(j,1) - bottom)/interval * level; 
    scoreM(j) = ceil(scoreM(j));
    if(scoreM(j)>100)
        scoreM(j) = 100;
    elseif(scoreM(j)<0)
        scoreM(j) = 0;
    end
end
fcmM = {centreM, UM, indexM};

intv = [];
% UF = {zeros(ncF(1),cF), zeros(ncF(2),cF), zeros(ncF(3),cF), zeros(ncF(4),cF)};
% centreF = {zeros(1,ncF(1)), zeros(1,ncF(2)), zeros(1,ncF(3)), zeros(1,ncF(4))};
% indexF = {zeros(1,cF), zeros(1,cF), zeros(1,cF), zeros(1,cF)};
[centreF, UF] = fcm(Fnew(:,1), ncF); %ģ������
for j = 1:cF
    [tmp,indexF(j)] = max(UF(:,j));  %ȷ��ÿ�������������
end
for j = 1:ncF %���
    top = min(3, max(Fnew(indexF==j,1)));
    bottom = max(-3, min(Fnew(indexF==j,1)));
    intv(j) = top - bottom;
end
interval = 0.5 * min(intv); 
bottom = max(-3, min(Fnew(:,1)));
top = min(3, max(Fnew(:,1)));
level = 70 * interval /(top-bottom);
for j = 1:cF
    scoreF(j) = 30 + (Fnew(j,1) - bottom)/interval * level; 
    scoreF(j) = ceil(scoreF(j));
    if(scoreF(j)>100)
        scoreF(j) = 100;
    elseif(scoreF(j)<0)
        scoreF(j) = 0;
    end
end
fcmF = {centreF, UF, indexF};

end
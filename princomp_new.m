%%
clc;clear;
load('clean_data.mat');
Dt = cleandata(:, [3 4 5 6 7 8 9 10 11 12 13]);
D = table2array(Dt);
[length, count] = size(D);
%%
for i = 1:length
    D(i,12) = D(i,6)/D(i,3);
end
[length, count] = size(D);
%%
cM = 0;
cF = 0;
for i = 1:length
    if(D(i, 1) == 1)
        cM = cM + 1;
        for j = 2:count
            if(j==7)
                M(cM, j-1) = 50.0/D(i, j);
            elseif(j==10)
                  M(cM, j-1) = 400.0/D(i, j);  
            else
                M(cM, j-1) = D(i, j);
            end
        end
    else
        cF = cF + 1;
        for k = 2:count
            if(k==7)
                F(cF, k-1) = 50.0/D(i, k);
            elseif(k==10)
                F(cF, k-1) = 400.0/D(i, k);
            else
                F(cF, k-1) = D(i, k);
            end
        end
    end
end

%%
RM = corrcoef(M);
RF = corrcoef(F);

%%
Mgroup{1} = M(:,[1 2 5]); %身高 体重 肺活量
Mgroup{2} = M(:,[2 3 4 11]); %体重 BMI分数 BMI 肺活量指数
Mgroup{3} = M(:,[6 8 9 10]); %50m 跳绳 400m 引体向上
Mgroup{4} = M(:,[6 8 9 10 11]); %50m 跳绳 400m 引体向上 肺活量指数
Fgroup{1} = F(:,[1 2 5]); %身高 体重 肺活量
Fgroup{2} = F(:,[2 3 4 11]); %体重 BMI分数 BMI 肺活量指数
Fgroup{3} = F(:,[6 8 9 10]); %50m 跳绳 400m 引体向上
Fgroup{4} = F(:,[6 8 9 10 11]); %50m 跳绳 400m 引体向上 肺活量指数

%%
for i = 1:4
    [pcaF{i}, pcaM{i}, fcmF{i}, fcmM{i}, scoreF{i}, scoreM{i}] = pca_fcm_score(Mgroup{i}, Fgroup{i});
end


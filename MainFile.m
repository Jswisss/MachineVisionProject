clc, close all
%Before Run this program perform the following action
%To run Google Cloud API you will need to go to this link to gain access to
%the api: https://accounts.google.com/o/oauth2/auth/oauthchooseaccount?client_id=1034295166782-rh8ve68jjes4d19pm9658642l4bcn1mc.apps.googleusercontent.com&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-translation&response_type=code&service=lso&o2v=1&theme=glif&flowName=GeneralOAuthFlow
% email: mltesttranslateapi@gmail.com
% password: Thisisfortesting!
%Swap out this code variable for the authorization code created through
%trusting Translation Project
code = '4/1AfJohXnmH5jf3qYmo2WotS-dMH1y1R9RTx3sRsMhDDiQDPPpIX5ndRMzGOk';

authkey = "AIzaSyDxW8kTGeBU-1umhYfb-t_N5mKu8TZBTjw";
inputImage = imread('Real sign.png');
figure(3), imshow(inputImage, [])
%Phase 1
imageTextData = ocr(inputImage,'Language','japanese');
textFound = imageTextData.Text;
textString = convertCharsToStrings(textFound);
bourdary = imageTextData.TextLineBoundingBoxes;
textSize = abs(bourdary(1,2) - bourdary(1,4));
if(textSize>60)
    textSize = 60;
end
%Phase 2
uri = "https://translation.googleapis.com/language/translate/v2";
method = matlab.net.http.RequestMethod.POST;
client_id = '1034295166782-rh8ve68jjes4d19pm9658642l4bcn1mc.apps.googleusercontent.com';
client_secret = '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';
url_1 = 'https://accounts.google.com/o/oauth2/token';
redirect_uri = 'urn:ietf:wg:oauth:2.0:oob';
%Once you run this code once comment out our data object, accessResponse,
%and access_token
data = [...
 'redirect_uri=', redirect_uri,... 
 '&client_id=', client_id,...
 '&client_secret=', client_secret,...
 '&grant_type=', 'authorization_code',...
 '&code=', code];
accessResponse = webwrite(url_1,data);
access_token = accessResponse.access_token;
package = '{"q": ["'+textString+'"], "target": "en-US",}';
%Once you run this file one time, copy the access code generated in the
%workspace and replace the old access token with the one generated.
%access_token = "ya29.a0AfB_byCFk2x6Ij0mER0VfS5qFyWcs9Bc7o9wh25rLxuczYZAq_lB5bDxNuOy2oA5QmAQcXWthhK_Eem0qUanBvOiGiLAX7ExISGORBjesSV5E8A8FLdS4ecTYmS7OLy_esK-XmML1rHQs5VS39MJYhxBGLu1FlKMNGWbaCgYKATUSARMSFQHGX2MiGXkSAjiDE32V1j0SZwOGnQ0171";
body = matlab.net.http.MessageBody(package);
header= matlab.net.http.HeaderField( "Authorization", "Bearer "+access_token, "x-goog-user-project", "metal-music-402401","ContentType", "application/json; charset=utf-8");
request = matlab.net.http.RequestMessage(method,header,body);
[response,completedrequest,history] = send(request,uri);
translatedTextChar= response.Body.Data.data.translations.translatedText;
translatedTextString = convertCharsToStrings(translatedTextChar);
%Phase 3
[I,A]=CreateImage(translatedTextString,'FontSize',textSize);   %fast repeat calls
figure(2),imshow(I,[])
%Phase 4
[inputR, inputC, inputD] = size(inputImage);
output= inputImage;
yBourdary = bourdary(1,2);
xBourdary = bourdary(1,1);
[row, col, depth] = size(I);
for currentR = 1:1:row
    for currentC = 1:1:col
        for currentD = 1:1: depth
        outputRIndex = currentR+ yBourdary - 1;
        outputCIndex = currentC + xBourdary - 1;
        output(outputRIndex, outputCIndex, currentD) = I(currentR, currentC, currentD);
        end
    end
end
figure(1),imshow(output,[])
clc, close all
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
code = '4/1AfJohXnmH5jf3qYmo2WotS-dMH1y1R9RTx3sRsMhDDiQDPPpIX5ndRMzGOk';
%data = [...
% 'redirect_uri=', redirect_uri,... 
% '&client_id=', client_id,...
% '&client_secret=', client_secret,...
% '&grant_type=', 'authorization_code',...
% '&code=', code];
%accessResponse = webwrite(url_1,data);
%access_token = accessResponse.access_token;
package = '{"q": ["'+textString+'"], "target": "en-US",}';
access_token = "ya29.a0AfB_byCFk2x6Ij0mER0VfS5qFyWcs9Bc7o9wh25rLxuczYZAq_lB5bDxNuOy2oA5QmAQcXWthhK_Eem0qUanBvOiGiLAX7ExISGORBjesSV5E8A8FLdS4ecTYmS7OLy_esK-XmML1rHQs5VS39MJYhxBGLu1FlKMNGWbaCgYKATUSARMSFQHGX2MiGXkSAjiDE32V1j0SZwOGnQ0171";
body = matlab.net.http.MessageBody(package);
header= matlab.net.http.HeaderField( "Authorization", "Bearer "+authkey, "x-goog-user-project", "metal-music-402401","ContentType", "application/json; charset=utf-8");
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
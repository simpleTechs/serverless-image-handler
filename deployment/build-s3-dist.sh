echo "------------------------------------------------------------------------------"
echo "Setup the dist folder"
echo "------------------------------------------------------------------------------"
rm -r dist 
mkdir dist
cd dist
mkdir demo-ui
cd ..

echo "------------------------------------------------------------------------------"
echo "Copy in the template"
echo "------------------------------------------------------------------------------"
cp *.template dist/ 
 
replace="s/%%BUCKET_NAME%%/$1/g" 
sed -i '' -e $replace dist/*.template 
 
replace="s/%%TEMPLATE_BUCKET%%/$2/g" 
sed -i '' -e $replace dist/*.template 
 
replace="s/%%VERSION%%/$3/g" 
sed -i '' -e $replace dist/*.template 
 
cd ../source 

echo "------------------------------------------------------------------------------"
echo "Package the image-handler code"
echo "------------------------------------------------------------------------------"
cd image-handler
# cross compile to linux in order to run sharp on lambda!
docker run -v "$PWD":/var/task lambci/lambda:build-nodejs10.x npm install --arch=x64 --platform=linux --target=10.17.0
docker run -v "$PWD":/var/task lambci/lambda:build-nodejs10.x npm run build --arch=x64 --platform=linux --target=10.17.0
cp dist/image-handler.zip ../../deployment/dist/image-handler.zip 

echo "------------------------------------------------------------------------------"
echo "Package the demo-ui assets"
echo "------------------------------------------------------------------------------"
cd ..
cp -r ./demo-ui/** ../deployment/dist/demo-ui

echo "------------------------------------------------------------------------------"
echo "Package the custom-resource code"
echo "------------------------------------------------------------------------------"
cd custom-resource
npm install 
npm run build 
cp dist/custom-resource.zip ../../deployment/dist/custom-resource.zip 

echo "------------------------------------------------------------------------------"
echo "Generate the demo-ui manifest document"
echo "------------------------------------------------------------------------------"
cd ../../deployment/manifest-generator
npm install
node app.js --target ../../source/demo-ui --output ../dist/demo-ui-manifest.json
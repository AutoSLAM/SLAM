To load the depth images in Matlab (say depth2 into a variable x), and then show it in imshow with scaling, run the following in Matlab:

```
x = load('depth2.mat');
imshow(x.imd,[])
```

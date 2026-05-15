using System;
using System.Threading.Tasks;
using Android.Graphics;
using Android.Media;

namespace Ninehoto.Android.Services
{
    public class ImageProcessor
    {
        private static ImageProcessor? _instance;
        public static ImageProcessor Instance => _instance ??= new ImageProcessor();

        private ImageProcessor() { }

        public Bitmap ResizeImage(Bitmap original, int targetWidth, int targetHeight)
        {
            float widthRatio = (float)targetWidth / original.Width;
            float heightRatio = (float)targetHeight / original.Height;
            float scaleFactor = Math.Min(widthRatio, heightRatio);

            int scaledWidth = (int)(original.Width * scaleFactor);
            int scaledHeight = (int)(original.Height * scaleFactor);

            return Bitmap.CreateScaledBitmap(original, scaledWidth, scaledHeight, true);
        }

        public Bitmap? CropImage(Bitmap original, int x, int y, int width, int height)
        {
            try
            {
                return Bitmap.CreateBitmap(original, x, y, width, height);
            }
            catch
            {
                return null;
            }
        }

        public Bitmap RotateImage(Bitmap original, float degrees)
        {
            var matrix = new Android.Graphics.Matrix();
            matrix.PostRotate(degrees);
            return Bitmap.CreateBitmap(original, 0, 0, original.Width, original.Height, matrix, true);
        }

        public Bitmap ConvertToGrayscale(Bitmap original)
        {
            var result = Bitmap.CreateBitmap(original.Width, original.Height, Bitmap.Config.Rgb565);
            var canvas = new Android.Graphics.Canvas(result);
            var paint = new Paint();
            
            var colorMatrix = new ColorMatrix();
            colorMatrix.SetSaturation(0);
            paint.SetColorFilter(new ColorMatrixColorFilter(colorMatrix));
            
            canvas.DrawBitmap(original, 0, 0, paint);
            return result;
        }

        public async Task<Bitmap?> GenerateVideoThumbnailAsync(string videoPath)
        {
            return await Task.Run(() =>
            {
                try
                {
                    var retriever = new MediaMetadataRetriever();
                    retriever.SetDataSource(videoPath);
                    var bitmap = retriever.GetFrameAtTime(1000000); // 1 second
                    retriever.Release();
                    return bitmap;
                }
                catch
                {
                    return null;
                }
            });
        }

        public Bitmap ApplyBlur(Bitmap original, float radius)
        {
            var input = new RenderScript(rs);
            var output = input.Allocate(original.Width, original.Height);
            
            var script = ScriptIntrinsicBlur.Create(input, Element.U8_4(rs));
            script.SetRadius(radius);
            script.SetInput(input);
            script.ForEach(output);
            
            var result = Bitmap.CreateBitmap(original.Width, original.Height, Bitmap.Config.Argb8888);
            output.CopyTo(result);
            
            input.Destroy();
            output.Destroy();
            
            return result;
        }

        public byte[] CompressImage(Bitmap original, int quality = 80)
        {
            using (var stream = new System.IO.MemoryStream())
            {
                original.Compress(Bitmap.CompressFormat.Jpeg, quality, stream);
                return stream.ToArray();
            }
        }

        public ImageMetadata GetImageMetadata(Bitmap bitmap)
        {
            return new ImageMetadata
            {
                Width = bitmap.Width,
                Height = bitmap.Height,
                HasAlpha = bitmap.HasAlpha,
                IsMutable = bitmap.IsMutable
            };
        }

        private Android.RenderScript.RenderScript rs;

        public void Initialize(Android.Content.Context context)
        {
            rs = Android.RenderScript.RenderScript.Create(context);
        }
    }

    public class ImageMetadata
    {
        public int Width { get; set; }
        public int Height { get; set; }
        public bool HasAlpha { get; set; }
        public bool IsMutable { get; set; }

        public float AspectRatio => Height > 0 ? (float)Width / Height : 1;
        public bool IsPortrait => AspectRatio < 1;
        public bool IsLandscape => AspectRatio > 1;
        public bool IsSquare => Math.Abs(AspectRatio - 1) < 0.01f;
    }
}
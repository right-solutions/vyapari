class Image::ProductImage < Image::Base
	mount_uploader :image, ProductImageUploader
end

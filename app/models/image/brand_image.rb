class Image::BrandImage < Image::Base
	mount_uploader :image, BrandImageUploader
end

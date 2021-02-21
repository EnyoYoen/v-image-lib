module image

import arrays { merge }
import os

#flag -I @VROOT/c
//#flag @VROOT/c/puff.o
#include "puff.h"

fn C.puff(&u32, charptr, &u32, charptr) int

struct PNG {
	pub:
	// IHDR : Image header
	width u32
	height u32
	bit_depth byte
	color_type byte
	compression_method byte
	filter_method byte
	interlace_method byte

	// PLTE : Palette
	palette []byte

	// Raw data from IDAT : Image data 
	raw_data []byte

	// bKGD : Background color
	background_color byte

	// cHRM : Primary chromaticities
	chromaticities []byte

	// dSIG : Digital signature
	digital_signature []byte

	// eXIf : EXIF
	exif_data []byte

	// gAMA : Image gamma
	gamma u32

	// hIST : Palette histogram
	palette_histogram u16

	// iCCP : Embedded ICC profile
	icc_profile []byte

	// iTXt : International textual data
	inter_text_data []byte

	// pHYs : Physical pixel dimensions
	pixel_per_x u32
	pixel_per_y u32
	unit byte

	// sBIT : Significant bits
	singnificant_bits []byte

	// sPLT : Suggested palette
	suggest_palette []byte

	// sRGB : Standard RGB color space
	standart_rgb byte

	// sTER : Stereo image indicator
	stereo_image_indic byte

	// tEXt : Textual information
	text []byte

	// tIME : Image last-modification time
	year u16
	month byte
	day byte
	hour byte
	minute byte
	second byte

	// tRNS : Transparency
	transparency []byte

	// zTXt : Compressed textual data
	compressed_text []byte
}

/*struct ICCP {
	profile_name string
	null_separator byte
	compression_method byte
	compression_profile []byte
}*/

fn bytes2string(b []byte) string {
	mut copy := b.clone()
	copy << byte(`\0`)
	return unsafe { tos(copy.data, copy.len - 1) }
}

fn in_array_at(researched_array []byte, research_array []byte, index int) bool
{
	if researched_array.len < research_array.len
	{
		for i := index ; i < index + researched_array.len ; i++
		{
			if researched_array[i - index] != research_array[i]
			{
				return false
			}
		}
		return true
	} else {
		return false
	}
}

fn in_array(researched_array []byte, research_array []byte) bool
{
	if researched_array.len < research_array.len
	{
		for i := 0 ; i < research_array.len ; i++
		{
			if researched_array[0] == research_array[i]
			{
				if in_array_at(researched_array, research_array, i)
				{
					return true
				}
			}
		}
		return false
	}
	return false
}

fn pow(base u16, exponent byte) u32
{
	mut result := u32(1)
	for i := exponent ; i > 0 ; i--
	{
		result *= base
	}
	return result
}

fn sum(length_chunk_part []byte) u32
{
	mut sum := u32(0)
	for i in 0..4
	{
		sum += length_chunk_part[i] * pow(256, 3 - byte(i))
	}
	return sum
}

fn check_integrity(image []byte)
{
	if !in_array_at([byte(0x89), 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A], image, 0)
	{
		panic('Invalid png signature')
	}

	if !in_array([byte(0x49), 0x48, 0x44, 0x52], image)
	{
		panic('IDHR chunk is missing')
	}

	if !in_array([byte(0x49), 0x44, 0x41, 0x54], image)
	{
		panic('IDAT chunk is missing')
	}

	if !in_array([byte(0x49), 0x45, 0x4E, 0x44], image)
	{
		panic('IEND chunk is missing')
	}
}

pub fn print_content(path string)
{
	image := os.read_bytes(path) or { panic(err) }
	check_integrity(image)
	println(image)
}

pub fn load_png_image(path string) PNG
{
	image := os.read_bytes(path) or { panic(err) }
	check_integrity(image)
	// IHDR : Image header
	mut width := u32(0)
	mut height := u32(0)
	mut bit_depth := byte(0)
	mut color_type := byte(0)
	mut compression_method := byte(0)
	mut filter_method := byte(0)
	mut interlace_method := byte(0)

	// PLTE : Palette
	mut palette := []byte{}

	// IDAT : Image data 
	mut data := []byte{}

	// bKGD : Background color
	mut background_color := byte(0)

	// cHRM : Primary chromaticities
	mut chromaticities := []byte{}

	// dSIG : Digital signature
	mut digital_signature := []byte{}

	// eXIf : EXIF
	mut exif_data := []byte{}

	// gAMA : Image gamma
	mut gamma := u32(0)

	// hIST : Palette histogram
	mut palette_histogram := u16(0)

	// iCCP : Embedded ICC profile
	mut icc_profile := []byte{}

	// iTXt : International textual data
	mut inter_text_data := []byte{}

	// pHYs : Physical pixel dimensions
	mut pixel_per_x := u32(0)
	mut pixel_per_y := u32(0)
	mut unit := byte(0)

	// sBIT : Significant bits
	mut singnificant_bits := []byte{}

	// sPLT : Suggested palette
	mut suggest_palette := []byte{}

	// sRGB : Standard RGB color space
	mut standart_rgb := byte(0)

	// sTER : Stereo image indicator
	mut stereo_image_indic := byte(0)

	// tEXt : Textual information
	mut text := []byte{}

	// tIME : Image last-modification time
	mut year := u16(0)
	mut month := byte(0)
	mut day := byte(0)
	mut hour := byte(0)
	mut minute := byte(0)
	mut second := byte(0)

	// tRNS : Transparency
	mut transparency := []byte{}

	// zTXt : Compressed textual data
	mut compressed_text := []byte{}

	mut i := u32(8)
	for
	{
		data_length := sum(image[i..i+4])
		chunk_name := bytes2string(image[i+4..i+8])
		chunk_data := image[i+8..i+8+data_length]
		i += data_length + 12
		match chunk_name {
			'IHDR' { 
				width = sum(chunk_data[0..4])
				height = sum(chunk_data[4..8])
				bit_depth = chunk_data[8]
				color_type = chunk_data[9]
				compression_method = chunk_data[10]
				filter_method = chunk_data[11]
				interlace_method = chunk_data[12]
			}
			'PLTE' {
				palette = chunk_data.clone()
			}
			'IDAT' {
				data = merge(data, chunk_data)
			}
			'IEND' {
				break
			}
			'bKGD' {
				background_color = chunk_data[0]
			}
			'cHRM' {
				chromaticities = chunk_data.clone()
			}
			'dSIG' {
				digital_signature = chunk_data.clone()
			}
			'eXIf' {
				exif_data = chunk_data.clone()
				// TODO : Register all exif data in a exif structure
			}
			'gAMA' {
				gamma = sum(chunk_data)
			}
			'hIST' {
				palette_histogram = chunk_data[0] + chunk_data[1] * 256
			}
			'iCCP' {
				icc_profile = chunk_data.clone()
			}
			'iTXt' {
				inter_text_data = chunk_data.clone()
			}
			'pHYs' {
				pixel_per_x = sum(chunk_data[0..4])
				pixel_per_y = sum(chunk_data[4..8])
				unit = chunk_data[8]
			}
			'sBIT' {
				singnificant_bits = chunk_data.clone()
			}
			'sPLT' {
				suggest_palette = chunk_data.clone()
			}
			'sRGB' {
				standart_rgb = chunk_data[0]
			}
			'sTER' {
				stereo_image_indic = chunk_data[0]
			}
			'tEXt' {
				text = chunk_data.clone()
			}
			'tIME' {
				year = chunk_data[1] + chunk_data[0] * 256
				month = chunk_data[2]
				day = chunk_data[3]
				hour = chunk_data[4]
				minute = chunk_data[5]
				second = chunk_data[6]
			}
			'tRNS' {
				transparency = chunk_data.clone()
			}
			'zTXt' {
				compressed_text = chunk_data.clone()
			}
			else {}
		}
	}

	raw_data := charptr(0)
	len := u64(4294967295)
	C.puff(raw_data, &len, &data, &data.len)

	/*return PNG {
		width: 				width
		height: 			height
		bit_depth: 			bit_depth
		color_type: 		color_type
		compression_method: compression_method
		filter_method: 		filter_method
		interlace_method: 	interlace_method
		palette: 			palette
		raw_data: 			raw_data
		background_color: 	background_color
		chromaticities: 	chromaticities
		digital_signature: 	digital_signature
		exif_data: 			exif_data
		gamma: 				gamma
		palette_histogram: 	palette_histogram
		icc_profile: 		icc_profile
		inter_text_data: 	inter_text_data
		pixel_per_x: 		pixel_per_x
		pixel_per_y: 		pixel_per_y
		unit: 				unit
		singnificant_bits: 	singnificant_bits
		suggest_palette: 	suggest_palette
		standart_rgb: 		standart_rgb
		stereo_image_indic: stereo_image_indic
		text: 				text
		year: 				year
		month: 				month
		day: 				day
		hour: 				hour
		minute: 			minute
		second: 			second
		transparency: 		transparency
		compressed_text: 	compressed_text
	}*/
	return PNG {}
}

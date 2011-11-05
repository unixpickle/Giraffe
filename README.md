Giraffe
=======

Giraffe is a legacy name for a GIF encoder that I wrote long ago. Now, the GIF encoding library used in this project is ANGif, a much better, more advanced GIF encoder. The soul purpose of this repository is to provide an example of how one might use ANGif in an iOS project.

Someone with the intention of using ANGif in their project should have a look at both the <tt>UIImagePixelSource.m</tt> and <tt>ExportViewController.m</tt> files. These are what use ANGif in conjunction with ANImageBitmapRep to export GIF images on the iPhone. ANGif itself does not require ANImageBitmapRep to work, but my example does require it.

ANGif Example
-------------

Just to give a sense of the easy-to-use ANGif library, here is an example of what encoding an animated GIF could look like:

    ANGifEncoder * encoder = [[ANGifEncoder alloc] initWithOutputFile:@"myFile.gif" size:CGSizeMake(100, 100) globalColorTable:nil];
    [encoder addApplicationExtension:[[ANGifNetscapeAppExtension alloc] init]];
    [encoder addImageFrame:anImageFrame];
    [encoder addImageFrame:anotherImageFrame];
    [encoder closeFile];

The <tt>addImageFrame:</tt> method takes an instance of <tt>ANGifImageFrame</tt>, which can be created in several different ways. In order to provide a UIImage to work with ANGif, a class must be made that implements the <tt>ANGifImageFramePixelSource</tt> protocol. In Giraffe, the <tt>UIImagePixelSource</tt> class is a simple UIImage wrapper that implements this protocol. The <tt>ANGifImageFrame</tt> object is also what includes the delay time (a.k.a. frame rate).

License
=======

	Copyright (c) 2011 Alex Nichol
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:
	1. Redistributions of source code must retain the above copyright
	   notice, this list of conditions and the following disclaimer.
	2. Redistributions in binary form must reproduce the above copyright
	   notice, this list of conditions and the following disclaimer in the
	   documentation and/or other materials provided with the distribution.
	3. The name of the author may not be used to endorse or promote products
	   derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
	IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
	OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
	IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
	THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
	THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

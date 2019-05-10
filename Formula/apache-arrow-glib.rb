class ApacheArrowGlib < Formula
  desc "GLib bindings for Apache Arrow"
  homepage "https://arrow.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=arrow/arrow-0.13.0/apache-arrow-0.13.0.tar.gz"
  sha256 "ac2a77dd9168e9892e432c474611e86ded0be6dfe15f689c948751d37f81391a"
  revision 1

  bottle do
    sha256 "ec0c08a84ad0d172d4db2981b1f1e511b8f7eab7de12ef75c2cbcad1a1599872" => :mojave
    sha256 "4d4b5983b16adb5bf50b6c07b08b752ff90e5e6c2223165543b0c2d05e00ddbb" => :high_sierra
    sha256 "9a0e6a53881bd60ae0a12b5b51aa7c4c9f575480ccdcea54484e8711c644c9f2" => :sierra
  end

  depends_on "gobject-introspection" => :build
  depends_on "pkg-config" => :build
  depends_on "apache-arrow"
  depends_on "glib"

  def install
    cd "c_glib" do
      system "./configure", "--prefix=#{prefix}"
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~SOURCE
      #include <arrow-glib/arrow-glib.h>
      int main(void) {
        GArrowNullArray *array = garrow_null_array_new(10);
        g_object_unref(array);
        return 0;
      }
    SOURCE
    apache_arrow = Formula["apache-arrow"]
    glib = Formula["glib"]
    flags = %W[
      -I#{include}
      -I#{apache_arrow.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -L#{lib}
      -L#{apache_arrow.opt_lib}
      -L#{glib.opt_lib}
      -DNDEBUG
      -larrow-glib
      -larrow
      -lglib-2.0
      -lgobject-2.0
      -lgio-2.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

pkg_tar(
    name = "pkg",
    srcs = glob(["**/*"]),
    strip_prefix = ".",
    package_dir = "AvrToolchain",
    mode = "0644",
    visibility = ["//visibility:public"],
)
{
  description = "4DenoiseNet - PyTorch Intel XPU (comfyui-nix style)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      python = pkgs.python312;

      # -------------------------------------------------------------------
      # 20+ Intel oneAPI runtime wheels → ONE combined lib/ directory.
      # All SYCL, MKL, oneCCL, TBB, UMF, PTI, etc. .so files live together
      # so cross-wheel SONAME resolution works (no RPATH/LD_LIBRARY_PATH
      # hacks needed per library).  autoPatchelfHook adds this single dir
      # to libtorch_xpu.so's RPATH.
      # -------------------------------------------------------------------
      fetch = url: sha256: builtins.fetchurl { inherit url sha256; };

      wheel = attrs: with attrs; pkgs.fetchurl { inherit url sha256; };

      intelOneapiRuntime = pkgs.stdenv.mkDerivation {
        pname = "intel-oneapi-runtime";
        version = "2025.3";

        srcs = [
          (wheel {
            url = "https://files.pythonhosted.org/packages/3d/66/26dfd6a19f7faf595da12c21bdb4102c6f30755511c7f167f745b203fbb7/intel_cmplr_lib_rt-2025.3.1-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-V/ZXqklEJyPlkQL7nj9etweZ2TceynqyrUb0T6zyEM8=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/70/9a/a338de7fc24087c40d38401372618c8465103795baefe941eea3acf55678/intel_cmplr_lib_ur-2025.3.1-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-FzDM4MZVkdFX1foazchEep7UGbUn6lLmbbCBWg+15EQ=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/a7/3b/30ce9123fd5368ac4f9abceca8cd7ee2f495c3e2b6f1b244285737210a8d/intel_cmplr_lic_rt-2025.3.1-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-rWUcJpBpK/jJQO5lomuwY9BpWafirSdyL27bvx9TykY=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/76/74/27684e2d0d32923da293f22b418c0c13919839444b67e86a8986f44938e7/intel_sycl_rt-2025.3.1-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-KW2UWY4VC/bqTFqPFQX5jopIO/OLaTW43a1vcrHSW58=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/6f/69/761af812bbccc4decd4f5b7492aa533654773ae9dfc3487edec44a4d8126/oneccl_devel-2021.17.1-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-w/dDjxK5dj3SvLPOT0iyRieIU0lHVFpoEX9QO5qwHSo=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/3d/69/8050e96e5b099b349d9109f727ce39b4f57414a24d3eb71a12fdc48bad87/oneccl-2021.17.1-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-x3sWoWhtJS7OffMx2o5P7rN3bEC90DqPjplCrTeNj/g=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/26/f9/4d676df06d5069144d1533a52860401ae9204cfe84ab69dc59a595233464/impi_rt-2021.17.0-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-e2XFpenfii/gzJjuWkTqThj5Dn0RhHq2ufmw31nB0Do=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/88/11/b43e8cde058c368ce7f8f9b1ca9f812f7397e4309148da7d24cb6b81b513/onemkl_license-2025.3.0-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-qBCyW7JKkNtEktgccc3hMYPYlRziaWDW3FbU9OPclf8=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/1e/07/df0cd5b0ec5f0a0bcbc8e73e4b2cfca78449b3b521868b1e366bfe6f97a3/onemkl_sycl_blas-2025.3.0-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-57tfKK/ARfy72JiRT0d9fnU17J+0W7lG7Z+Be9HvH1s=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/7c/b8/1ec88922a9a479f567183cf82d49041451bcb7afbb3195202d9a57e5a0ff/onemkl_sycl_dft-2025.3.0-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-OuI/OCDwZRyLQ8/2Rt3STawpOCr2yyS/RtXIpHLIuJk=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/78/c4/c2cf3e1990707f7f1918f1073e3a26c56e92f06c1525af39501b271ede23/onemkl_sycl_lapack-2025.3.0-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-0qTXuia5CrM6L2TtbJXFlshyHuJRmD6vmkyYVtHjTHs=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/94/6a/3fc34f47c69bdfbfce1f6d02f18e0fd41459bb4e1204e2a5cae179c0986e/onemkl_sycl_rng-2025.3.0-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-5EBkG3waAhxJdblbmYKLgBVQSNiQ6/0k80Bg/qpbM3U=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/a9/5f/4f0b81e5f83f5e42c549bd29a9398b507890ec24080d27cd7afada61521e/onemkl_sycl_sparse-2025.3.0-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-kwzS0UquWhv+wH+hC4F8REeDRTqhplVA3kbgy/nQDeY=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/9a/1f/ff1b20fe45c1a2077f1a11e2447826881987a76983facab763a72ee29fc8/dpcpp_cpp_rt-2025.3.1-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-ZWTxncV0XAC0nqdJUt8TwmxOI6ogtykpKKMNdeOE+YY=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/8b/de/6a4fa1e6e1ff1441a4197f08c92798367074f98e4f43ce0d94f36913ae90/intel_opencl_rt-2025.3.1-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-9Ux5f9g5ueXkQciU6rDhrcg5SgazxN84BFItYAWmYdk=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/6d/b4/ef531295ed33b929c6c5214421eeebe370f1be22536b6956b4aaf18fdbc5/mkl-2025.3.0-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-e4H10uA0Y3sYfKWGZoeMToiJmIp4454LbukuhGVo9mA=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/da/ad/72e2fb7e30f5fd2b7650b721c5979cf2a614538fd99afb45672b31157fb9/intel_openmp-2025.3.1-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-LDVB6idfDoQXJDYSoWtvH00Vwen8yWZn2wgk0HNfFBM=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/e3/9e/b7f1f7af53580e4e8cf39cf51b14c8e295d767b3ae9d78b5007d6058cfc8/tbb-2022.3.0-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-p+Eiy5im+II5QDQaoyPc3/+nfjZxKiKhrjp2Qw+p9BI=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/a1/a4/38e8b5a27b66ab286168ba6c449771ed71d71ec76524e7f12401474a5151/tcmlib-1.4.1-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-DVvZjbSNMb7H/tulwjWZv5rkPHAW1MOUbSUkLTIM7ok=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/27/8e/4a90b6aa955268988e7491f502b7ac2bd65cb954b4979bfcc892cf019b50/umf-1.0.2-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-700USiAHpzoaIu5XXuT1oYlKIGUyxvbXe0z1SGQ1Avs=";
          })
          (wheel {
            url = "https://files.pythonhosted.org/packages/f4/f0/56874c288e637e1b8619813d5a928778a712e96456f19a2ca1f52b4c9eb0/intel_pti-0.15.0-py2.py3-none-manylinux_2_28_x86_64.whl";
            sha256 = "sha256-Yp+9+0wXAZh9zJ+OLAP8GLPsmrXIRi7p3nHJbGK4Lsw=";
          })
        ];

        nativeBuildInputs = [
          pkgs.unzip
          pkgs.autoPatchelfHook
        ];
        buildInputs = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          level-zero
          numactl
          libffi
        ];
        autoPatchelfIgnoreMissingDeps = [
          "libze_intel_gpu.so.1"
          "librdmacm.so.1"
          "libibverbs.so.1"
          "libefa.so.1"
          "libpsm2.so.2"
          "libucp.so.0"
          "libpsm3-fi.so"
          "libnuma.so.1"
          "libffi.so"
          "libuuid.so.1"
          "libmlx-fi.so"
          "libverbs-1.12-fi.so"
          "libverbs-1.1-fi.so"
          "libefa-fi.so"
        ];

        dontConfigure = true;
        dontBuild = true;
        sourceRoot = ".";

        unpackPhase = ''
          for whl in $srcs; do
            mkdir -p "wheel_$(basename "$whl" .whl)"
            unzip -q "$whl" -d "wheel_$(basename "$whl" .whl)"
          done
        '';

        installPhase = ''
          mkdir -p $out/lib
          for wheel_dir in wheel_*; do
            [ -d "$wheel_dir" ] || continue
            for data_lib in "$wheel_dir"/*.data/data/lib; do
              [ -d "$data_lib" ] && cp -rn "$data_lib"/. "$out/lib/" 2>/dev/null || true
            done
            [ -d "$wheel_dir/lib" ] && cp -rn "$wheel_dir/lib"/. "$out/lib/" 2>/dev/null || true
          done
        '';

        dontStrip = true;
      };

      # -------------------------------------------------------------------
      # PyTorch 2.10.0 XPU + torchvision 0.25.0
      # -------------------------------------------------------------------
      torch-xpu = python.pkgs.buildPythonPackage rec {
        pname = "torch";
        version = "2.10.0+xpu";
        format = "wheel";
        src = pkgs.fetchurl {
          url = "https://download.pytorch.org/whl/xpu/torch-2.10.0%2Bxpu-cp312-cp312-linux_x86_64.whl";
          sha256 = "sha256-tHNXHUeJEvkogcwT8V+hj4Rj+w+4oGjJbtR6fUWk2go=";
        };
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          intelOneapiRuntime
        ];
        propagatedBuildInputs = with python.pkgs; [
          filelock
          typing-extensions
          sympy
          networkx
          jinja2
          fsspec
          setuptools
        ];
        propagatedNativeBuildInputs = [ intelOneapiRuntime ];
        autoPatchelfIgnoreMissingDeps = [ "libze_intel_gpu.so.1" ];
        doCheck = false;
        dontCheckRuntimeDeps = true;
        postInstall = ''
          for metadata in "$out/${python.sitePackages}"/torch-*.dist-info/METADATA; do
            [[ -f "$metadata" ]] || continue
            sed -i -E '/^Requires-Dist: (dpcpp-|impi-|intel-|mkl|oneccl|onemkl-|tbb|tcmlib|triton|umf)/d' "$metadata"
          done
        '';
      };

      torchvision-xpu = python.pkgs.buildPythonPackage {
        pname = "torchvision";
        version = "0.25.0+xpu";
        format = "wheel";
        src = pkgs.fetchurl {
          url = "https://download.pytorch.org/whl/xpu/torchvision-0.25.0%2Bxpu-cp312-cp312-manylinux_2_28_x86_64.whl";
          sha256 = "sha256-atJUNJa8KeWdPdYUqU0JqphwMYrttmBFNE//3f7dLPg=";
        };
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [
          torch-xpu
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
        ];
        autoPatchelfIgnoreMissingDeps = [
          "libc10.so"
          "libc10_xpu.so"
          "libtorch.so"
          "libtorch_cpu.so"
          "libtorch_xpu.so"
          "libtorch_python.so"
        ];
        propagatedBuildInputs = [
          torch-xpu
          python.pkgs.numpy
          python.pkgs.pillow
        ];
        doCheck = false;
      };

      customPython = python.withPackages (ps: [
        torch-xpu
        torchvision-xpu
        ps.pyyaml
        ps.matplotlib
        ps.opencv4
        ps.scipy
        ps.tensorboard
        ps.vispy
        ps.imageio
        ps.pyglet
      ]);

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "4denoisenet-xpu";

        packages = with pkgs; [
          customPython
          intel-compute-runtime
          level-zero
          gcc
        ];

        # System GPU driver + C++ runtime; NO companion wheel hacks needed.
        LD_LIBRARY_PATH = lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
          pkgs.intel-compute-runtime
          pkgs.level-zero
        ];

        shellHook = ''
                    export DNNL_DEFAULT_NUM_THREADS=1
                    export OMP_NUM_THREADS=1
                    export ZESILENT=0
                    export ZE_AFFINITY_MASK=0
                    export SYCL_DEVICE_FILTER=ext_oneapi_level_zero:gpu:0
                    export VISPY_BACKEND=pyglet

                    echo "========================================"
                    echo "  4DenoiseNet - Intel Arc XPU"
                    echo "  PyTorch ${torch-xpu.version} (combined oneAPI runtime)"
                    echo "========================================"

                    # pip-only packages not in nixpkgs
                    pip install pykitti --quiet 2>/dev/null

                    python3 <<'PYTEST'
          import sys, torch
          ver = torch.__version__
          has_xpu = hasattr(torch, "xpu") and torch.xpu.is_available()
          print(f"PyTorch {ver} | XPU: {'AVAILABLE' if has_xpu else 'UNAVAILABLE'}")
          if not has_xpu:
              sys.exit(1)
          for i in range(torch.xpu.device_count()):
              print(f"  GPU {i}: {torch.xpu.get_device_name(i)}")
          a = torch.randn((512, 512), device="xpu")
          b = torch.randn((512, 512), device="xpu")
          c = a @ b
          torch.xpu.synchronize()
          print("matmul: OK")
          PYTEST
        '';
      };
    };
}

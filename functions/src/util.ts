export const getIsProd = () => {
  return process.env["GCLOUD_PROJECT"] === "sukimachi-f89b0";
};
export const getIsEmulator = () => {
  return process.env["FUNCTIONS_EMULATOR"] === "true";
};

export const developDomain = "https://sukimachi-dev-58429.web.app";
export const productDomain = "https://sukimachi.app";

export const getAdminDomain = () => {
  return getIsProd()
    ? "https://sukimachi-cms.web.app"
    : "https://sukimachi-dev-cms.web.app";
};

// 実行環境を返す
export const environment = () => {
  switch (true) {
    case getIsProd(): {
      return "本番環境";
    }
    case getIsEmulator(): {
      return "Emulator";
    }
    default: {
      return "開発環境";
    }
  }
};

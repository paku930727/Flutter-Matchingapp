const hostname = location.hostname;
const port = location.port;

const developClientId =
  "1032148406582-nqn3rcn7q8dilhavrlu96v01g2of3imo.apps.googleusercontent.com";
const productsClientId =
  "910420795240-bh95aa7295j486if6ir4e2s1p4kk8l2d.apps.googleusercontent.com";

function replaceGoogleSignInMeta(value) {
  console.log(document.querySelector('meta[name="google-signin-client_id"]'));
  document
    .querySelector('meta[name="google-signin-client_id"]')
    .setAttribute("content", value);
}

const firebaseConfig = (() => {
  switch (hostname) {
    case "localhost":
      if (port == "3333") {
        //開発環境-local
        replaceGoogleSignInMeta(developClientId);
      }
      if (port == "3334") {
        // 本番環境-local
        replaceGoogleSignInMeta(productsClientId);
      }
      break;
    case "sukimachi-dev-58429.web.app":
      //開発環境-deploy
      replaceGoogleSignInMeta(developClientId);
      break;
    case "sukimachi.app":
      // 本番環境-deploy
      replaceGoogleSignInMeta(productsClientId);
      break;
  }
})();

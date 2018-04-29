# discord

This is an project aimed to provide bare HTTP proxy under 4G/LTE with multiple proxy auto-config File or manual configuration, allowing you to manage your network with multiple PAC files. Since I'm just an amateur to Swift development and the project itself is more like a proof of concept prototype, instead of some serious long-term maintainable engineering product, I won't provide any kind of warranty, or any kind of "will fix ASAP" promise. For the same reason, I will also not write any kind of Test/Unit Test.

It will keep free, without any kind of advertisement or In-App-Purchase. If you really enjoy using this app, think about star my project: https://github.com/cnnblike/discord.git

**YOU SHOULD ALSO BE AWARE, ANY KIND OF OPEN PROXY IS DANGEROUS, JUST USE THE ONE YOU CAN TRUST!**

To implement this, I've used several open-source project, including, but not limited to: [Alamofire/Alamofire](https://github.com/Alamofire/Alamofire), [Alamofire/AlamofireImage](https://github.com/Alamofire/AlamofireImage), [zhuhaow/NEKit](https://github.com/zhuhaow/NEKit). Many thanks to these awesome project and their developer.

## Demo QR image

![](./Capture.PNG)

## How to build a QR Code conform to this app

This app accept QR code in two different content:

1. only one url to the PAC file. or

1. a JSON object with, but not limited to one of the following field pattern:

    a. `host` field + `port` field. The app will automatically interpreter the QR code as an authenticate-less proxy.

    b. `host` field + `port` field + `username` field + `password` field. The app will interpreter the QR code as a configuration for a proxy with authentication.

    c. `pacUrl` field or `pacContent` field. It will be interpreted as a PAC proxy.

To have an advanced configuration, we have even more configuration field available via JSON string QR scanner:

1. `enable`: is this proxy rule actually active?

1. `isAutomatic`: is this rule a Proxy Auto-Config one? Or it's a dumb "applied to all" rule?

1. `needAuthenticate`: is this proxy an authenticate one?

1. `username`: the username for proxy authentication

1. `host`: proxy host for manual.

1. `port`: proxy port for manual.

1. `password`: the password used for authentication

1. `pacUrl`: the url for pac file, used in automatic proxy.

1. `name`: field showing in the main ViewController.

1. `descriptor`: field for detail description in main ViewController.

1. `imageUrl`: field for image shown in main ViewController.

1. `pacContent`: this field contains what's in the pac file. **Only configurable via QR JSON.**

## How to build on your own

1. install dependency

```bash
carthage update --no-use-binaries --platform ios
```

## Development related

1. TODO

Internalization

LOGO(a better one)

Fix the leftover of images related to deleted/modified rules

1. LICENSE

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

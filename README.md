browser-jstp
============

Client side (browser) ready JavaScript library for [JSTP](https://github.com/southlogics/jstp-rfc).

> Here you can find [the Node.js implementation](https://github.com/southlogics/node-jstp)

Download
--------

Plain JavaScript: [download](https://raw.github.com/Fetcher/client-side-jstp/master/js/jstp.js)

CoffeeScript: [download](https://raw.github.com/Fetcher/client-side-jstp/master/coffee/jstp.coffee)

Usage
-----

> (you can find this example [in the example folder](example)

In the HTML:

```html
<!doctype html>
<html>
  <head>
    <title>Some JSTP sample</title>
    <script type="text/javascript" src="jstp.js"></script>
    <script type="text/javascript">
      function doSomething() {
        JSTP.post({
          resource: ['Salutation'],
          body: "Hello World!"  
        });
      }
      
      var actions = {
        salute: function (dispatch) {
          document.write(dispatch.body);
        }
      }
      
      JSTP.bind({
        endpoint: {
          method: 'POST',
          resource: ['Salutation']
        }
      }, actions.salute, actions);
    </script>
  </head>

  <body>
    <button onclick="doSomething()">Do something</button>
  </body>
</html>
```

License
-------

Copyright © 2013 SouthLogics

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

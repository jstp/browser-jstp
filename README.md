browser-jstp
============

Client side (browser) ready JavaScript library for JSTP.

Download
--------

Plain JavaScript: [download](https://raw.github.com/Fetcher/client-side-jstp/master/js/jstp.js)

CoffeeScript: [download](https://raw.github.com/Fetcher/client-side-jstp/master/coffee/jstp.coffee)

Usage
-----

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

```javascript

```

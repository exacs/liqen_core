# LiqenCore

The Core of Liqen, rewritten.

## Why?

In the past, we created Liqen Core as a Web Application using the [Phoenix Framework](http://phoenixframework.com).

Now, the framework is updated to version 1.3. And, if you have seen [this video presentating it](https://www.youtube.com/watch?v=tMO28ar0lW8) you will notice a change of mindset to develop with it.

So, LiqenCore is no longer a Web Application created using Phoenix.

Now, it is an Elixir Application with a Web layer on top of it.

## The Application vs The Web Interface

- All the code concerning the Application itself (including the business logic) is under the `LiqenCore` module in the `lib/liqen_core` directory
- The web interface is under the `LiqenCoreWeb` module in the `lib/liqen_core_web` directory

Check them out!

## Read more

Generate the docs using:

```sh
mix docs
```

Then open `/doc/index.html`

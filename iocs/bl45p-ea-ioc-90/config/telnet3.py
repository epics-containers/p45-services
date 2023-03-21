import asyncio

import click
from telnetlib3 import open_connection


@click.group()
def cli():
    pass


async def user_input(writer):
    loop = asyncio.events._get_running_loop()

    while True:
        # run the wait for input in a separate thread
        cmd = await loop.run_in_executor(None, input)
        writer.write(cmd)
        writer.write("\r")


async def server_output(reader):
    while True:
        out_p = await reader.read(1024)
        if not out_p:
            raise EOFError("Connection closed by server")
        print(out_p, flush=True, end="")


async def shell(reader, writer):
    # user input and server output in separate tasks
    tasks = [
        server_output(reader),
        user_input(writer),
    ]

    await asyncio.gather(*tasks)


async def runner(hostname: str, port: int, reboot: bool):
    reader, writer = await open_connection(hostname, port)

    writer.write("\r")
    await asyncio.sleep(0.1)
    prompt = await reader.read(1024)
    print(f"prompt is {prompt.strip()}")

    if reboot:
        writer.write("exit\r")

    reader.close()
    writer.close()

    # start interactive session
    reader, writer = await open_connection(hostname, port, shell=shell)
    await writer.protocol.waiter_closed


@cli.command()
@click.argument("hostname", type=str)
@click.argument("port", type=int)
@click.option("--reboot", type=bool, default=False)
def connect(hostname: str, port: int, reboot: bool):
    asyncio.run(runner(hostname, port, reboot))


cli.add_command(connect)
if __name__ == "__main__":
    cli()

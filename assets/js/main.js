import smcat from 'state-machine-cat'

const statechartToSVG = (ast) => {
  return smcat.render(ast, {
    inputType: 'json',
    outputType: 'svg'
  })
}

export function init(ctx, ast) {
  // ctx.root.innerHTML = JSON.stringify(smcat)
  const svg = statechartToSVG(ast)
  const parser = new DOMParser()
  const svgNode = parser.parseFromString(svg, "image/svg+xml").documentElement

  console.log(svgNode)

  ctx.root.appendChild(svgNode)
}

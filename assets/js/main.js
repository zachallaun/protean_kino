import smcat, { render } from 'state-machine-cat'

const statechartToSVG = (ast) => {
  return smcat.render(ast, {
    inputType: 'json',
    outputType: 'svg'
  })
}

const renderSVG = (ast, target) => {
  const svg = statechartToSVG(ast)
  const parser = new DOMParser()
  const svgNode = parser.parseFromString(svg, "image/svg+xml").documentElement
  target.replaceChildren(svgNode)
}

export function init(ctx, ast) {
  renderSVG(ast, ctx.root)

  ctx.handleEvent("replace", ast => {
    renderSVG(ast, ctx.root)
  })
}

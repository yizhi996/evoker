//
//  Canvas2DView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class Canvas2DView: UIView {
    
    typealias Action = ([Any], CGContext) -> Void
    
    static let commandActions: [Canvas2DMethod: Action] = {
        return [
            .setMiterLimit: { command, ctx in
                if command.count == 2, let limit = command[1] as? CGFloat {
                    ctx.setMiterLimit(limit)
                }
            },
            .setLineJoin: { command, ctx in
                if command.count == 2, let join = command[1] as? String {
                    if join == "round" {
                        ctx.setLineJoin(.round)
                    } else if join == "bevel" {
                        ctx.setLineJoin(.bevel)
                    } else if join == "miter" {
                        ctx.setLineJoin(.miter)
                    }
                }
            },
            .setLineWidth: { command, ctx in
                if command.count == 2, let width = command[1] as? CGFloat {
                    ctx.setLineWidth(width)
                }
            },
            .setAlpha: { command, ctx in
                if command.count == 2, let alpha = command[1] as? CGFloat {
                    ctx.setAlpha(alpha)
                }
            },
            .scale: { command, ctx in
                if command.count == 3, let x = command[1] as? CGFloat, let y = command[2] as? CGFloat {
                    ctx.scaleBy(x: x, y: y)
                }
            },
            .rotate: { command, ctx in
                if command.count == 2, let angle = command[1] as? CGFloat {
                    ctx.rotate(by: angle)
                }
            },
            .translate: { command, ctx in
                if command.count == 3, let x = command[1] as? CGFloat, let y = command[2] as? CGFloat {
                    ctx.translateBy(x: x, y: y)
                }
            },
            .transform: { command, ctx in
                if command.count == 7,
                   let a = command[1] as? CGFloat,
                   let b = command[2] as? CGFloat,
                   let c = command[3] as? CGFloat,
                   let d = command[4] as? CGFloat,
                   let tx = command[5] as? CGFloat,
                   let ty = command[6] as? CGFloat {
                    ctx.concatenate(CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty))
                }
            },
            .setTransform: { command, ctx in
                
            },
            .save: { command, ctx in
                ctx.saveGState()
            },
            .restore: { command, ctx in
                ctx.restoreGState()
            },
            .strokeRect: { command, ctx in
                if command.count == 5,
                   let x = command[1] as? CGFloat,
                   let y = command[2] as? CGFloat,
                   let width = command[3] as? CGFloat,
                   let height = command[4] as? CGFloat {
                    ctx.stroke(CGRect(x: x, y: y, width: width, height: height))
                }
            },
            .clearRect: { command, ctx in
                if command.count == 5,
                   let x = command[1] as? CGFloat,
                   let y = command[2] as? CGFloat,
                   let width = command[3] as? CGFloat,
                   let height = command[4] as? CGFloat {
                    ctx.clear(CGRect(x: x, y: y, width: width, height: height))
                }
            },
            .clip: { command, ctx in
                ctx.clip()
            },
            .resetClip: { command, ctx in
                ctx.resetClip()
            },
            .closePath: { command, ctx in
                ctx.closePath()
            },
            .moveTo: { command, ctx in
                if command.count == 3, let x = command[1] as? CGFloat, let y = command[2] as? CGFloat {
                    ctx.move(to: CGPoint(x: x, y: y))
                }
            },
            .lineTo: { command, ctx in
                if command.count == 3, let x = command[1] as? CGFloat, let y = command[2] as? CGFloat {
                    ctx.addLine(to: CGPoint(x: x, y: y))
                }
            },
            .quadraticCurveTo: { command, ctx in
                if command.count == 5,
                   let cpx = command[1] as? CGFloat,
                   let cpy = command[2] as? CGFloat,
                   let x = command[3] as? CGFloat,
                   let y = command[4] as? CGFloat {
                    ctx.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: cpx, y: cpy))
                }
            },
        ]
    }()
    
    var commands: [[Any]] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        commands.forEach { command in
            if !command.isEmpty,
               let value = command[0] as? Int,
               let method = Canvas2DMethod(rawValue: value) {
                Canvas2DView.commandActions[method]?(command, ctx)
            }
        }
        commands = []
    }
    
    func execDrawCommands(_ commands: [[Any]]) {
        self.commands = commands
        setNeedsDisplay()
        
    }
}
